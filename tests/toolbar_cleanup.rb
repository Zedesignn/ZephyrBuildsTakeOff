# 工具栏清理脚本 - 解决工具栏重复叠加问题
puts "🧹 工具栏清理脚本 v1.1"
puts "=" * 50

# 检查UI.toolbars是否可用
unless UI.respond_to?(:toolbars)
  puts "\n❌ 当前SketchUp版本不支持UI.toolbars方法"
  puts "请使用更新版本的SketchUp或手动管理工具栏"
  return false
end

begin
  # 1. 查找现有的Zephyr工具栏
  puts "\n🔍 查找现有的Zephyr Wall Tool工具栏..."

  all_toolbars = UI.toolbars
  zephyr_toolbars = all_toolbars.select do |toolbar|
    toolbar.name.include?('Zephyr') || toolbar.name.include?('Wall')
  end

  puts "找到 #{zephyr_toolbars.length} 个相关工具栏："
  zephyr_toolbars.each_with_index do |toolbar, index|
    puts "  #{index + 1}. #{toolbar.name} (可见: #{toolbar.visible?})"
  end

  # 2. 隐藏所有相关工具栏
  puts "\n🚫 隐藏所有Zephyr相关工具栏..."
  zephyr_toolbars.each do |toolbar|
    begin
      if toolbar.visible?
        toolbar.hide
        puts "  ✅ 隐藏: #{toolbar.name}"
      else
        puts "  ℹ️ 已隐藏: #{toolbar.name}"
      end
    rescue => e
      puts "  ❌ 隐藏失败: #{toolbar.name} - #{e.message}"
    end
  end

  # 3. 清理变量引用
  puts "\n🗑️ 清理变量引用..."
  
  if defined?(@@zephyr_toolbar)
    @@zephyr_toolbar = nil
    puts "  ✅ 清理 @@zephyr_toolbar"
  end

  if defined?(@zephyr_toolbar)
    @zephyr_toolbar = nil
    puts "  ✅ 清理 @zephyr_toolbar"
  end

  # 4. 垃圾回收
  puts "\n♻️ 执行垃圾回收..."
  GC.start
  puts "  ✅ 垃圾回收完成"

  # 5. 显示清理后状态
  puts "\n📊 清理后状态："
  remaining_toolbars = UI.toolbars.select do |toolbar|
    toolbar.name.include?('Zephyr') || toolbar.name.include?('Wall')
  end

  if remaining_toolbars.empty?
    puts "  ✅ 没有找到Zephyr相关工具栏"
  else
    puts "  剩余工具栏："
    remaining_toolbars.each_with_index do |toolbar, index|
      puts "    #{index + 1}. #{toolbar.name} (可见: #{toolbar.visible?})"
    end
  end

  puts "\n🎉 工具栏清理完成！"
  true

rescue => e
  puts "\n❌ 工具栏清理失败: #{e.message}"
  puts "📍 错误位置: #{e.backtrace.first}"
  false
end

# 辅助函数
def reset_zephyr_toolbars
  return false unless UI.respond_to?(:toolbars)
  
  puts "\n🔄 执行工具栏重置..."
  
  UI.toolbars.each do |toolbar|
    if toolbar.name.include?('Zephyr') || toolbar.name.include?('Wall')
      toolbar.hide if toolbar.visible?
    end
  end
  
  if defined?(@@zephyr_toolbar)
    @@zephyr_toolbar = nil
  end
  
  GC.start
  puts "✅ 工具栏重置完成"
  true
end

puts "\n💡 可用函数："
puts "  reset_zephyr_toolbars    # 重置Zephyr工具栏"
puts "\n🔧 如果问题仍然存在："
puts "1. 重启SketchUp"
puts "2. 重新加载插件" 