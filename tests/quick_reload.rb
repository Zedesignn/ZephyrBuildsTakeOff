#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Zephyr Wall Tool 快速重载脚本
# 用于在SketchUp Ruby控制台中快速重载插件，无需重启SketchUp

puts "🔄 开始重载 Zephyr Wall Tool 插件..."

begin
  # 1. 清理现有的常量和变量
  puts "📝 清理现有常量..."
  
  # 移除模块常量
  if Object.const_defined?(:ZephyrWallTool)
    Object.send(:remove_const, :ZephyrWallTool)
    puts "✅ 已移除 ZephyrWallTool 常量"
  end
  
  if Object.const_defined?(:ZephyrWallToolLoader)
    Object.send(:remove_const, :ZephyrWallToolLoader)
    puts "✅ 已移除 ZephyrWallToolLoader 常量"
  end

  # 2. 清理已加载的文件缓存
  puts "🗑️ 清理文件缓存..."
  
  # 获取当前工作目录
  current_dir = File.dirname(__FILE__)
  plugin_dir = File.join(current_dir, 'zephyr_wall_tool')
  
  # 清理相关的已加载文件
  files_to_remove = []
  $LOADED_FEATURES.each do |feature|
    if feature.include?('zephyr_wall_tool') || feature.include?('ZephyrWallTool')
      files_to_remove << feature
    end
  end
  
  files_to_remove.each do |feature|
    $LOADED_FEATURES.delete(feature)
    puts "🗑️ 已从缓存中移除: #{File.basename(feature)}"
  end

  # 3. 强制垃圾回收
  puts "🧹 执行垃圾回收..."
  GC.start
  
  # 4. 重新加载插件
  puts "📦 重新加载插件..."
  
  # 使用绝对路径加载主入口文件
  loader_path = File.join(plugin_dir, 'zephyr_wall_tool_loader.rb')
  
  if File.exist?(loader_path)
    load loader_path
    puts "✅ 成功加载: #{File.basename(loader_path)}"
  else
    puts "❌ 找不到加载器文件: #{loader_path}"
    raise "插件加载器文件不存在"
  end
  
  # 5. 初始化插件
  puts "🚀 初始化插件..."
  
  if defined?(ZephyrWallToolLoader)
    ZephyrWallToolLoader.initialize_plugin
    puts "✅ 插件初始化完成"
  else
    puts "⚠️ ZephyrWallToolLoader 未定义，尝试手动初始化..."
    
    # 手动加载核心文件
    core_path = File.join(plugin_dir, 'core.rb')
    if File.exist?(core_path)
      load core_path
      puts "✅ 成功加载核心文件"
    end
  end
  
  # 6. 验证加载结果
  puts "🔍 验证加载结果..."
  
  if defined?(ZephyrWallTool)
    puts "✅ ZephyrWallTool 模块已加载"
    
    # 检查主要方法是否可用
    if ZephyrWallTool.respond_to?(:manage_types)
      puts "✅ manage_types 方法可用"
    else
      puts "⚠️ manage_types 方法不可用"
    end
    
    if ZephyrWallTool.respond_to?(:all_types)
      types = ZephyrWallTool.all_types
      puts "✅ 当前有 #{types.length} 个墙体类型"
    else
      puts "⚠️ all_types 方法不可用"
    end
  else
    puts "❌ ZephyrWallTool 模块未加载"
  end
  
  puts "🎉 插件重载完成！"
  puts ""
  puts "💡 使用提示："
  puts "   - 运行 ZephyrWallTool.manage_types 打开管理界面"
  puts "   - 运行 ZephyrWallTool.all_types 查看所有墙体类型"
  puts "   - 菜单项需要重启SketchUp才能完全清理"
  puts ""

rescue => e
  puts "❌ 重载失败: #{e.message}"
  puts "📍 错误位置: #{e.backtrace.first}"
  puts ""
  puts "🔧 故障排除建议："
  puts "   1. 确保插件文件完整"
  puts "   2. 检查文件权限"
  puts "   3. 尝试重启SketchUp"
  puts ""
end