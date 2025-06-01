#!/usr/bin/env ruby
# package_plugin.rb - SketchUp插件智能打包工具
# 确保每次打包都检查文件结构，符合SketchUp规范

require 'fileutils'
require 'zip'

class SketchUpPluginPackager
  def initialize(plugin_name = nil, version = nil)
    @plugin_name = plugin_name || detect_plugin_name
    @version = version || detect_version
    @base_name = @plugin_name.downcase.gsub(/\s+/, '_')
    @entry_file = "#{@base_name}.rb"
    @plugin_dir = @base_name
    @output_file = "#{@plugin_name.gsub(/\s+/, '_')}_v#{@version}.rbz"
    
    puts "📋 插件信息:"
    puts "   名称: #{@plugin_name}"
    puts "   版本: #{@version}"
    puts "   入口文件: #{@entry_file}"
    puts "   插件目录: #{@plugin_dir}"
    puts "   输出文件: #{@output_file}"
    puts
  end

  def package
    puts "🚀 开始打包 #{@plugin_name} v#{@version}"
    puts "=" * 50
    
    begin
      # 1. 验证文件结构
      validate_structure
      
      # 2. 清理临时文件
      cleanup_temp_files
      
      # 3. 创建打包
      create_package
      
      # 4. 验证打包结果
      validate_package
      
      puts "=" * 50
      puts "✅ 打包成功完成!"
      puts "📦 输出文件: #{@output_file}"
      puts "📊 文件大小: #{File.size(@output_file) / 1024}KB"
      puts "🎯 可以安装到SketchUp了!"
      
    rescue => e
      puts "❌ 打包失败: #{e.message}"
      exit 1
    end
  end

  private

  def detect_plugin_name
    # 尝试从现有的.rb文件检测插件名
    rb_files = Dir.glob('*.rb').reject { |f| f == 'package_plugin.rb' }
    if rb_files.length == 1
      File.basename(rb_files.first, '.rb').split('_').map(&:capitalize).join(' ')
    else
      "Zephyr Wall Tool"  # 默认值
    end
  end

  def detect_version
    # 尝试从现有的.rb文件检测版本
    rb_files = Dir.glob('*.rb').reject { |f| f == 'package_plugin.rb' }
    rb_files.each do |file|
      content = File.read(file)
      if content =~ /PLUGIN_VERSION\s*=\s*['"]([^'"]+)['"]/
        return $1
      end
      if content =~ /VERSION\s*=\s*['"]([^'"]+)['"]/
        return $1
      end
    end
    "3.2.2"  # 默认版本
  end

  def validate_structure
    puts "🔍 验证SketchUp插件文件结构..."
    
    errors = []
    warnings = []
    
    # 1. 检查主入口文件
    unless File.exist?(@entry_file)
      errors << "缺少主入口文件: #{@entry_file}"
    else
      puts "  ✅ 主入口文件存在: #{@entry_file}"
      
      # 检查入口文件内容
      entry_content = File.read(@entry_file)
      unless entry_content.include?('SketchupExtension.new')
        errors << "主入口文件缺少扩展注册代码 (SketchupExtension.new)"
      else
        puts "  ✅ 扩展注册代码正确"
      end
      
      unless entry_content.include?('file_loaded?')
        warnings << "建议在入口文件中使用 file_loaded? 检查"
      end
    end
    
    # 2. 检查插件目录
    unless Dir.exist?(@plugin_dir)
      errors << "缺少插件目录: #{@plugin_dir}"
    else
      puts "  ✅ 插件目录存在: #{@plugin_dir}"
      
      # 检查核心文件
      core_file = File.join(@plugin_dir, 'core.rb')
      if File.exist?(core_file)
        puts "  ✅ 核心文件存在: #{core_file}"
      else
        warnings << "未找到核心文件: #{core_file}"
      end
    end
    
    # 3. 检查文件命名一致性
    if File.basename(@entry_file, '.rb') != @plugin_dir
      errors << "入口文件名与插件目录名不匹配: #{@entry_file} vs #{@plugin_dir}/"
    else
      puts "  ✅ 文件命名一致性检查通过"
    end
    
    # 4. 检查是否有多余的入口文件
    rb_files = Dir.glob('*.rb').reject { |f| f == 'package_plugin.rb' || f == @entry_file }
    if rb_files.any?
      warnings << "发现额外的.rb文件，可能导致冲突: #{rb_files.join(', ')}"
    end
    
    # 显示警告
    if warnings.any?
      puts "  ⚠️  警告:"
      warnings.each { |warning| puts "     #{warning}" }
    end
    
    # 如果有错误，停止打包
    if errors.any?
      puts "  ❌ 结构验证失败:"
      errors.each { |error| puts "     #{error}" }
      raise "插件结构不符合SketchUp规范"
    end
    
    puts "  ✅ 文件结构验证通过"
  end

  def cleanup_temp_files
    puts "🧹 清理不需要的文件..."
    
    # 定义要排除的文件和目录模式
    exclude_patterns = [
      # 文档文件
      '*.md', '*.txt', 
      # 配置文件
      '*.yml', '*.yaml', '*.json',
      # Git文件
      '.git*', '.gitignore',
      # 系统文件
      '.DS_Store', 'Thumbs.db',
      # 开发目录
      'test/', 'spec/', 'dev-docs/', 'build/', 'dist/',
      # 脚本文件
      '*.sh', '*.bat',
      # 临时文件
      '*.tmp', '*.backup', '*~',
      # 编辑器文件
      '.vscode/', '.idea/', '.bundle/',
      # Ruby开发文件
      'Gemfile*', '.rubocop*'
    ]
    
    cleaned_count = 0
    exclude_patterns.each do |pattern|
      Dir.glob(pattern, File::FNM_DOTMATCH).each do |file|
        next if file == '.' || file == '..'
        next if file == 'package_plugin.rb'  # 保留打包脚本
        
        begin
          if File.directory?(file)
            FileUtils.rm_rf(file)
            puts "  删除目录: #{file}"
          else
            File.delete(file)
            puts "  删除文件: #{file}"
          end
          cleaned_count += 1
        rescue => e
          puts "  警告: 无法删除 #{file}: #{e.message}"
        end
      end
    end
    
    puts "  ✅ 清理完成，删除了 #{cleaned_count} 个文件/目录"
  end

  def create_package
    puts "📦 创建SketchUp插件包..."
    
    # 删除旧的包文件
    if File.exist?(@output_file)
      File.delete(@output_file)
      puts "  删除旧包文件: #{@output_file}"
    end
    
    file_count = 0
    
    Zip::File.open(@output_file, Zip::File::CREATE) do |zipfile|
      # 添加主入口文件
      if File.exist?(@entry_file)
        zipfile.add(@entry_file, @entry_file)
        puts "  ✅ 添加主入口: #{@entry_file}"
        file_count += 1
      end
      
      # 添加插件目录中的所有文件
      if Dir.exist?(@plugin_dir)
        Dir.glob("#{@plugin_dir}/**/*").each do |file|
          next if File.directory?(file)
          
          # 跳过不需要的文件
          next if should_exclude_file?(file)
          
          zipfile.add(file, file)
          puts "  ✅ 添加文件: #{file}"
          file_count += 1
        end
      end
    end
    
    puts "  ✅ 包创建完成，包含 #{file_count} 个文件"
  end

  def should_exclude_file?(file)
    # 不应包含在插件包中的文件类型
    exclude_extensions = ['.md', '.txt', '.yml', '.yaml', '.json', '.tmp', '.backup', '.log']
    exclude_names = ['.DS_Store', 'Thumbs.db', '.gitignore']
    
    # 检查文件扩展名
    return true if exclude_extensions.any? { |ext| file.downcase.end_with?(ext) }
    
    # 检查文件名
    return true if exclude_names.any? { |name| File.basename(file) == name }
    
    # 检查是否是测试文件
    return true if file.include?('_test.rb') || file.include?('_spec.rb')
    
    # 检查是否是隐藏文件
    return true if File.basename(file).start_with?('.')
    
    false
  end

  def validate_package
    puts "🔍 验证打包结果..."
    
    unless File.exist?(@output_file)
      raise "打包文件不存在: #{@output_file}"
    end
    
    # 检查包内容
    Zip::File.open(@output_file) do |zipfile|
      entries = zipfile.entries.map(&:name)
      
      puts "  📋 包内容 (#{entries.length} 个文件):"
      entries.sort.each { |entry| puts "     #{entry}" }
      
      # 必须包含主入口文件
      unless entries.include?(@entry_file)
        raise "包中缺少主入口文件: #{@entry_file}"
      end
      puts "  ✅ 主入口文件存在"
      
      # 检查是否包含插件目录
      plugin_files = entries.select { |entry| entry.start_with?("#{@plugin_dir}/") }
      if plugin_files.any?
        puts "  ✅ 插件目录文件存在 (#{plugin_files.length} 个)"
      else
        puts "  ⚠️  警告: 没有找到插件目录文件"
      end
      
      # 检查是否包含不应该有的文件
      unwanted_files = entries.select { |entry| should_exclude_file?(entry) }
      if unwanted_files.any?
        puts "  ⚠️  警告: 包含不需要的文件:"
        unwanted_files.each { |file| puts "       #{file}" }
      end
      
      # 检查包大小
      total_size = zipfile.entries.sum(&:size)
      if total_size > 10 * 1024 * 1024  # 10MB
        puts "  ⚠️  警告: 包文件较大 (#{total_size / 1024 / 1024}MB)"
      end
      
      puts "  ✅ 包验证通过"
    end
  end
end

# 主程序
if __FILE__ == $0
  puts "🎯 SketchUp插件智能打包工具"
  puts "确保符合SketchUp插件规范"
  puts

  # 从命令行参数读取，或使用自动检测
  plugin_name = ARGV[0]
  version = ARGV[1]
  
  begin
    packager = SketchUpPluginPackager.new(plugin_name, version)
    packager.package
  rescue Interrupt
    puts "\n❌ 用户中断打包"
    exit 1
  rescue => e
    puts "\n❌ 打包失败: #{e.message}"
    puts "💡 请检查文件结构是否符合SketchUp插件规范"
    exit 1
  end
end