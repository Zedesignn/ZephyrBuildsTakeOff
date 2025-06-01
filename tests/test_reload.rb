# 增强的测试重载脚本 - 验证Length类型修复
puts "🔄 开始增强测试重载..."

# 1. 清理现有模块
puts "🧹 清理现有模块..."
Object.send(:remove_const, :ZephyrWallTool) if defined?(ZephyrWallTool)
Object.send(:remove_const, :ZephyrWallToolLoader) if defined?(ZephyrWallToolLoader)

# 2. 清理加载的文件
puts "🗑️ 清理加载的文件..."
$LOADED_FEATURES.delete_if { |f| f.include?('zephyr_wall_tool') }

# 3. 强制垃圾回收
puts "♻️ 强制垃圾回收..."
GC.start

# 4. 重新加载
puts "📂 重新加载插件..."
loader_file = '/Users/Z/Downloads/Zephyr Builds Take Off/zephyr_wall_tool/zephyr_wall_tool_loader.rb'

if File.exist?(loader_file)
  load loader_file
  puts "✅ 加载成功"
  
  # 5. 初始化
  if defined?(ZephyrWallToolLoader)
    ZephyrWallToolLoader.initialize_plugin
    puts "✅ 初始化完成"
  else
    puts "❌ ZephyrWallToolLoader 未定义"
  end
  
  # 6. 验证修复
  if defined?(ZephyrWallTool)
    puts "✅ ZephyrWallTool 模块可用"
    
    # 测试墙体类型
    types = ZephyrWallTool.all_types
    puts "📊 当前有 #{types.length} 个墙体类型"
    
    # 🧪 SketchUp Length 运算规则测试
    puts ""
    puts "🧪 SketchUp Length 运算规则测试："
    puts "=" * 40
    
    # 创建测试Length对象
    test_length = 500.mm
    puts "原始长度: #{test_length} (#{test_length.class})"
    
    # 测试各种运算
    puts "\n📏 运算测试："
    multiply_result = test_length * 0.5
    divide_float_result = test_length / 2.0
    divide_int_result = test_length / 2
    
    puts "  乘以 0.5: #{multiply_result} (#{multiply_result.class})"
    puts "  除以 2.0: #{divide_float_result} (#{divide_float_result.class})"
    puts "  除以 2: #{divide_int_result} (#{divide_int_result.class})"
    
    # 验证类型保持
    puts "\n✅ 类型保持验证："
    puts "  乘法保持Length: #{multiply_result.is_a?(Length) ? '✅' : '❌'}"
    puts "  浮点除法保持Length: #{divide_float_result.is_a?(Length) ? '✅' : '❌'}"
    puts "  整数除法保持Length: #{divide_int_result.is_a?(Length) ? '✅' : '❌'}"
    
    # 测试第一个墙体类型的厚度（如果存在）
    if types.length > 0
      puts ""
      puts "🔍 墙体类型厚度测试："
      first_type = types.first
      thickness = first_type[:thickness]
      puts "第一个墙体类型厚度: #{thickness} (类型: #{thickness.class})"
      
      if thickness.is_a?(Length)
        # 测试修复后的偏移距离计算
        offset_multiply = thickness * 0.5
        offset_divide = thickness / 2
        
        puts "  偏移距离(乘法): #{offset_multiply} (#{offset_multiply.class})"
        puts "  偏移距离(除法): #{offset_divide} (#{offset_divide.class})"
        
        if offset_multiply.is_a?(Length)
          puts "  ✅ 修复成功！乘法保持Length类型"
        else
          puts "  ❌ 修复失败：乘法未保持Length类型"
        end
        
      else
        puts "  ⚠️ 厚度不是Length类型: #{thickness.class}"
      end
    end
    
    # 测试对话框清理功能
    puts ""
    puts "🧹 测试对话框清理功能："
    if ZephyrWallTool.respond_to?(:close_all_dialogs)
      puts "✅ close_all_dialogs 方法可用"
    else
      puts "❌ close_all_dialogs 方法不可用"
    end
    
  else
    puts "❌ ZephyrWallTool 模块不可用"
  end
  
  puts ""
  puts "🎉 增强测试重载完成！"
  puts ""
  puts "💡 测试命令："
  puts "   ZephyrWallTool.manage_types           # 打开管理界面"
  puts "   ZephyrWallTool.create_all_wall_tags   # 创建墙体Tags"
  puts "   ZephyrWallTool.generate_walls_from_tags # 从Tags生成墙体"
  puts ""
  puts "🔧 Length运算规则总结："
  puts "   Length * Float  → Length (✅ 推荐用于偏移距离)"
  puts "   Length / Float  → Float  (❌ 避免使用)"
  puts "   Length / Integer → Length (✅ 可用但不如乘法稳定)"
  
else
  puts "❌ 找不到加载器文件: #{loader_file}"
end

true 