# UI 清理测试脚本
puts "🧪 测试 UI 清理功能..."

begin
  # 检查模块是否已加载
  if defined?(ZephyrWallTool)
    puts "✅ ZephyrWallTool 模块已加载"
    
    # 测试对话框清理
    puts "\n🧹 测试对话框清理..."
    if ZephyrWallTool.respond_to?(:close_all_dialogs)
      closed_count = ZephyrWallTool.close_all_dialogs
      puts "📊 清理结果: 关闭了 #{closed_count} 个对话框"
    else
      puts "❌ close_all_dialogs 方法不可用"
    end
    
    # 测试打开对话框
    puts "\n🔄 测试打开管理界面..."
    if ZephyrWallTool.respond_to?(:manage_types)
      puts "📱 调用 manage_types..."
      ZephyrWallTool.manage_types
      puts "✅ 管理界面已打开"
    else
      puts "❌ manage_types 方法不可用"
    end
    
    puts "\n💡 现在您可以："
    puts "   1. 查看是否有重复的对话框"
    puts "   2. 再次运行 ZephyrWallTool.close_all_dialogs 来清理"
    puts "   3. 再次运行 ZephyrWallTool.manage_types 来测试重新打开"
    
  else
    puts "❌ ZephyrWallTool 模块未加载"
    puts "💡 请先运行: load '/Users/Z/Downloads/Zephyr Builds Take Off/test_reload.rb'"
  end
  
rescue => e
  puts "❌ 测试失败: #{e.message}"
  puts "📍 错误位置: #{e.backtrace.first}"
end

puts "\n🎯 快速命令："
puts "ZephyrWallTool.close_all_dialogs  # 清理所有对话框"
puts "ZephyrWallTool.manage_types       # 打开管理界面" 