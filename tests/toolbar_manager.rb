# 工具栏管理器 - 完整的工具栏管理解决方案
puts "🛠️ Zephyr Wall Tool 工具栏管理器 v1.0"
puts "=" * 50

# 工具栏管理器类
class ZephyrToolbarManager
  def self.show_all_toolbars
    puts "\n📋 所有工具栏列表："
    begin
      if UI.respond_to?(:toolbars)
        UI.toolbars.each_with_index do |toolbar, index|
          status = toolbar.visible? ? "✅ 可见" : "❌ 隐藏"
          puts "  #{index + 1}. #{toolbar.name} - #{status}"
        end
      else
        puts "  ⚠️ 当前SketchUp版本不支持工具栏管理"
      end
    rescue => e
      puts "  ❌ 获取工具栏列表失败: #{e.message}"
    end
  end

  def self.find_zephyr_toolbars
    return [] unless UI.respond_to?(:toolbars)
    
    begin
      UI.toolbars.select do |toolbar|
        toolbar.name.include?('Zephyr') || 
        toolbar.name.include?('Wall') ||
        toolbar.name.downcase.include?('zephyr') ||
        toolbar.name.downcase.include?('wall')
      end
    rescue => e
      puts "  ❌ 查找工具栏失败: #{e.message}"
      []
    end
  end

  def self.hide_all_zephyr_toolbars
    puts "\n🚫 隐藏所有Zephyr相关工具栏..."
    zephyr_toolbars = find_zephyr_toolbars
    
    if zephyr_toolbars.empty?
      puts "  ℹ️ 没有找到Zephyr相关工具栏"
      return 0
    end

    hidden_count = 0
    zephyr_toolbars.each do |toolbar|
      begin
        if toolbar.visible?
          toolbar.hide
          puts "  ✅ 隐藏: #{toolbar.name}"
          hidden_count += 1
        else
          puts "  ℹ️ 已隐藏: #{toolbar.name}"
        end
      rescue => e
        puts "  ❌ 隐藏失败: #{toolbar.name} - #{e.message}"
      end
    end

    puts "  📊 总共隐藏了 #{hidden_count} 个工具栏"
    hidden_count
  end

  def self.show_zephyr_toolbar
    puts "\n👁️ 显示Zephyr工具栏..."
    zephyr_toolbars = find_zephyr_toolbars
    
    if zephyr_toolbars.empty?
      puts "  ❌ 没有找到Zephyr工具栏，需要重新创建"
      return false
    end

    # 只显示第一个找到的工具栏
    toolbar = zephyr_toolbars.first
    begin
      if !toolbar.visible?
        toolbar.show
        puts "  ✅ 显示: #{toolbar.name}"
        return true
      else
        puts "  ℹ️ 已显示: #{toolbar.name}"
        return true
      end
    rescue => e
      puts "  ❌ 显示失败: #{toolbar.name} - #{e.message}"
      return false
    end
  end

  def self.clean_toolbar_cache
    puts "\n🧹 清理工具栏缓存..."
    
    # 1. 清理全局变量
    if defined?(@@zephyr_toolbar)
      @@zephyr_toolbar = nil
      puts "  ✅ 清理 @@zephyr_toolbar"
    end

    if defined?(@zephyr_toolbar)
      @zephyr_toolbar = nil
      puts "  ✅ 清理 @zephyr_toolbar"
    end

    # 2. 清理ZephyrWallToolLoader中的引用
    if defined?(ZephyrWallToolLoader)
      # 清理类变量
      ZephyrWallToolLoader.class_variables.each do |var|
        if var.to_s.include?('toolbar')
          puts "  清理ZephyrWallToolLoader类变量: #{var}"
          ZephyrWallToolLoader.remove_class_variable(var)
        end
      end

      # 清理实例变量
      ZephyrWallToolLoader.instance_variables.each do |var|
        if var.to_s.include?('toolbar')
          puts "  清理ZephyrWallToolLoader实例变量: #{var}"
          ZephyrWallToolLoader.remove_instance_variable(var)
        end
      end
    end

    # 3. 强制垃圾回收
    GC.start
    puts "  ✅ 执行垃圾回收"

    # 4. macOS特定清理
    if RUBY_PLATFORM.include?('darwin')
      puts "  🍎 执行macOS特定清理..."
      begin
        # 刷新UI系统
        if defined?(Sketchup.send_action)
          Sketchup.send_action("showRubyConsole:")
          sleep(0.05)
          Sketchup.send_action("showRubyConsole:")
        end
        puts "  ✅ macOS UI刷新完成"
      rescue => e
        puts "  ⚠️ macOS清理失败: #{e.message}"
      end
    end
  end

  def self.reset_toolbar_completely
    puts "\n🔄 完全重置工具栏..."
    
    # 1. 隐藏所有相关工具栏
    hide_all_zephyr_toolbars
    
    # 2. 清理缓存
    clean_toolbar_cache
    
    # 3. 等待一下确保清理完成
    sleep(0.2)
    
    # 4. 重新创建工具栏
    if defined?(ZephyrWallToolLoader)
      begin
        puts "  🔨 重新创建工具栏..."
        ZephyrWallToolLoader.create_toolbar
        puts "  ✅ 工具栏重新创建完成"
        return true
      rescue => e
        puts "  ❌ 重新创建失败: #{e.message}"
        return false
      end
    else
      puts "  ❌ ZephyrWallToolLoader未加载，无法重新创建"
      return false
    end
  end

  def self.check_status
    puts "\n📊 工具栏状态检查："
    
    # 检查所有Zephyr相关工具栏
    zephyr_toolbars = find_zephyr_toolbars
    puts "  找到 #{zephyr_toolbars.length} 个Zephyr相关工具栏："
    
    zephyr_toolbars.each_with_index do |toolbar, index|
      status = toolbar.visible? ? "✅ 可见" : "❌ 隐藏"
      puts "    #{index + 1}. #{toolbar.name} - #{status}"
    end

    # 检查变量引用
    puts "\n  📌 变量引用状态："
    if defined?(@@zephyr_toolbar) && @@zephyr_toolbar
      puts "    @@zephyr_toolbar: 存在 (#{@@zephyr_toolbar.name})"
    else
      puts "    @@zephyr_toolbar: 不存在"
    end

    if defined?(@zephyr_toolbar) && @zephyr_toolbar
      puts "    @zephyr_toolbar: 存在 (#{@zephyr_toolbar.name})"
    else
      puts "    @zephyr_toolbar: 不存在"
    end

    # 检查加载器状态
    if defined?(ZephyrWallToolLoader)
      puts "    ZephyrWallToolLoader: 已加载"
    else
      puts "    ZephyrWallToolLoader: 未加载"
    end
  end

  def self.interactive_menu
    puts "\n🎛️ 交互式工具栏管理菜单："
    puts "1. 显示所有工具栏"
    puts "2. 隐藏Zephyr工具栏"
    puts "3. 显示Zephyr工具栏"
    puts "4. 清理工具栏缓存"
    puts "5. 完全重置工具栏"
    puts "6. 检查状态"
    puts "7. 退出"
    
    choice = UI.inputbox(['选择操作 (1-7):'], ['1'], '工具栏管理')
    return unless choice

    case choice[0].to_i
    when 1
      show_all_toolbars
    when 2
      hide_all_zephyr_toolbars
    when 3
      show_zephyr_toolbar
    when 4
      clean_toolbar_cache
    when 5
      reset_toolbar_completely
    when 6
      check_status
    when 7
      puts "👋 退出工具栏管理器"
      return
    else
      puts "❌ 无效选择"
    end

    # 递归调用菜单
    interactive_menu
  end
end

# 主执行逻辑
puts "\n🔍 初始状态检查..."
ZephyrToolbarManager.check_status

puts "\n💡 可用命令："
puts "ZephyrToolbarManager.hide_all_zephyr_toolbars  # 隐藏所有Zephyr工具栏"
puts "ZephyrToolbarManager.reset_toolbar_completely  # 完全重置工具栏"
puts "ZephyrToolbarManager.check_status              # 检查状态"
puts "ZephyrToolbarManager.interactive_menu          # 交互式菜单"

puts "\n🚀 快速解决方案："
puts "如果工具栏重复，运行: ZephyrToolbarManager.reset_toolbar_completely"

# 如果发现重复工具栏，自动提示
zephyr_toolbars = ZephyrToolbarManager.find_zephyr_toolbars
if zephyr_toolbars.length > 1
  puts "\n⚠️ 检测到 #{zephyr_toolbars.length} 个Zephyr工具栏，建议重置！"
  puts "运行: ZephyrToolbarManager.reset_toolbar_completely"
end 