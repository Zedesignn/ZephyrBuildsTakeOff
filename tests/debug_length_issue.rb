# 深度调试 Length 类型问题
puts "🔍 深度调试 Length 类型问题"
puts "=" * 50

if defined?(ZephyrWallTool)
  # 获取墙体类型
  types = ZephyrWallTool.all_types
  puts "📊 当前有 #{types.length} 个墙体类型"
  
  if types.length > 0
    types.each_with_index do |wall_type, index|
      puts "\n🏗️ 墙体类型 #{index + 1}: #{wall_type[:name]}"
      thickness = wall_type[:thickness]
      puts "  原始厚度: #{thickness} (#{thickness.class})"
      
      # 测试各种计算方法
      puts "  🧪 测试各种计算方法："
      
      # 方法1: 直接乘法
      if thickness.is_a?(Length)
        offset1 = thickness * 0.5
        puts "    thickness * 0.5 = #{offset1} (#{offset1.class})"
      end
      
      # 方法2: 转换后乘法
      thickness_converted = thickness.is_a?(Numeric) ? thickness.to_l : thickness
      offset2 = thickness_converted * 0.5
      puts "    转换后 * 0.5 = #{offset2} (#{offset2.class})"
      
      # 方法3: 强制转换为Length
      if thickness.respond_to?(:to_l)
        thickness_forced = thickness.to_l
        offset3 = thickness_forced * 0.5
        puts "    强制转换后 * 0.5 = #{offset3} (#{offset3.class})"
      end
      
      # 方法4: 检查是否是Length对象的问题
      puts "  🔍 详细类型检查："
      puts "    thickness.is_a?(Length): #{thickness.is_a?(Length)}"
      puts "    thickness.class.ancestors: #{thickness.class.ancestors.first(5)}"
      puts "    thickness.respond_to?(:to_l): #{thickness.respond_to?(:to_l)}"
      puts "    thickness.respond_to?(:to_mm): #{thickness.respond_to?(:to_mm)}"
      
      # 方法5: 创建新的Length对象
      if thickness.respond_to?(:to_mm)
        thickness_mm = thickness.to_mm
        new_length = thickness_mm.mm
        offset4 = new_length * 0.5
        puts "    重新创建Length * 0.5 = #{offset4} (#{offset4.class})"
      end
    end
  end
  
  # 测试基础Length运算
  puts "\n🧪 基础 Length 运算测试："
  test_lengths = [100.mm, 200.mm, 500.mm]
  
  test_lengths.each do |test_length|
    puts "\n  测试长度: #{test_length} (#{test_length.class})"
    
    multiply_result = test_length * 0.5
    puts "    * 0.5 = #{multiply_result} (#{multiply_result.class})"
    
    divide_result = test_length / 2
    puts "    / 2 = #{divide_result} (#{divide_result.class})"
    
    divide_float_result = test_length / 2.0
    puts "    / 2.0 = #{divide_float_result} (#{divide_float_result.class})"
  end
  
  # 测试从毫米创建Length的方法
  puts "\n🔧 测试从毫米创建Length的方法："
  test_values = [100, 200, 500]
  
  test_values.each do |value|
    puts "\n  测试值: #{value}mm"
    
    # 方法1: 直接.mm
    length1 = value.mm
    offset1 = length1 * 0.5
    puts "    #{value}.mm * 0.5 = #{offset1} (#{offset1.class})"
    
    # 方法2: to_f.mm
    length2 = value.to_f.mm
    offset2 = length2 * 0.5
    puts "    #{value}.to_f.mm * 0.5 = #{offset2} (#{offset2.class})"
    
    # 方法3: 检查是否有精度问题
    puts "    length1 == length2: #{length1 == length2}"
    puts "    length1.class: #{length1.class}"
    puts "    length2.class: #{length2.class}"
  end
  
else
  puts "❌ ZephyrWallTool 模块未加载"
  puts "💡 请先运行: load '/Users/Z/Downloads/Zephyr Builds Take Off/test_reload.rb'"
end

puts "\n🎯 建议的修复方案："
puts "1. 确保重新加载了修复后的代码"
puts "2. 检查Length对象的创建方式"
puts "3. 验证乘法运算的结果类型"
puts "4. 考虑强制类型转换" 