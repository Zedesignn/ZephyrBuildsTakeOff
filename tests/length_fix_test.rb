# Length类型修复测试脚本
puts "🔧 Length类型修复测试脚本"
puts "=" * 50

# 检查插件是否已加载
unless defined?(ZephyrWallTool)
  puts "❌ ZephyrWallTool 模块未加载"
  puts "💡 请先运行: load '/Users/Z/Downloads/Zephyr Builds Take Off/tests/test_reload.rb'"
  exit
end

# 基础Length运算测试
puts "\n🧪 基础Length运算测试："
test_values = [100, 200, 400, 500]

test_values.each do |value|
  puts "\n测试值: #{value}mm"
  
  # 创建Length对象
  length = value.mm
  puts "  Length对象: #{length} (#{length.class})"
  
  # 测试乘法
  multiply_result = length * 0.5
  puts "  乘以0.5: #{multiply_result} (#{multiply_result.class}) #{multiply_result.is_a?(Length) ? '✅' : '❌'}"
  
  # 测试除法
  divide_result = length / 2.0
  puts "  除以2.0: #{divide_result} (#{divide_result.class}) #{divide_result.is_a?(Length) ? '✅' : '❌'}"
  
  # 测试整数除法
  divide_int_result = length / 2
  puts "  除以2: #{divide_int_result} (#{divide_int_result.class}) #{divide_int_result.is_a?(Length) ? '✅' : '❌'}"
  
  # 修复方法测试
  if !multiply_result.is_a?(Length)
    puts "  修复乘法结果: #{multiply_result.to_l} (#{multiply_result.to_l.class})"
  end
  
  if !divide_result.is_a?(Length)
    puts "  修复除法结果: #{divide_result.to_l} (#{divide_result.to_l.class})"
  end
end

# 测试墙体类型的厚度处理
puts "\n🏗️ 墙体类型厚度测试："
types = ZephyrWallTool.all_types

if types.empty?
  puts "❌ 没有墙体类型，创建测试类型..."
  # 创建一个测试类型
  test_type = {
    name: "测试墙体",
    color: "#808080",
    thickness: 400.mm,
    height: 3000.mm,
    tag: "ZephyrWall_测试墙体"
  }
  
  puts "测试类型厚度: #{test_type[:thickness]} (#{test_type[:thickness].class})"
  
  # 测试偏移距离计算
  thickness = test_type[:thickness]
  offset_distance = thickness * 0.5
  puts "偏移距离: #{offset_distance} (#{offset_distance.class}) #{offset_distance.is_a?(Length) ? '✅' : '❌'}"
else
  types.each_with_index do |wall_type, index|
    puts "\n墙体类型 #{index + 1}: #{wall_type[:name]}"
    thickness = wall_type[:thickness]
    puts "  厚度: #{thickness} (#{thickness.class})"
    
    # 确保是Length类型
    unless thickness.is_a?(Length)
      puts "  ⚠️ 厚度不是Length类型，转换中..."
      thickness = thickness.to_l
      puts "  转换后: #{thickness} (#{thickness.class})"
    end
    
    # 测试偏移距离计算
    offset_distance = thickness * 0.5
    puts "  偏移距离(乘法): #{offset_distance} (#{offset_distance.class}) #{offset_distance.is_a?(Length) ? '✅' : '❌'}"
    
    # 如果乘法失败，使用备用方法
    unless offset_distance.is_a?(Length)
      puts "  ⚠️ 乘法结果不是Length类型，使用备用方法..."
      thickness_mm = thickness.to_mm
      offset_distance_backup = (thickness_mm / 2.0).mm
      puts "  备用方法: #{offset_distance_backup} (#{offset_distance_backup.class}) #{offset_distance_backup.is_a?(Length) ? '✅' : '❌'}"
    end
  end
end

# 测试SketchUp版本和Length实现
puts "\n📋 SketchUp环境信息："
puts "SketchUp版本: #{Sketchup.version}"
puts "Ruby版本: #{RUBY_VERSION}"

# 测试Length类的方法
test_length = 100.mm
puts "\nLength对象方法测试:"
puts "  to_mm: #{test_length.to_mm} (#{test_length.to_mm.class})"
puts "  to_m: #{test_length.to_m} (#{test_length.to_m.class})"
puts "  to_l: #{test_length.to_l} (#{test_length.to_l.class})"
puts "  to_f: #{test_length.to_f} (#{test_length.to_f.class})"

# 测试不同的Length创建方法
puts "\n🔨 Length创建方法测试:"
methods = [
  ["100.mm", 100.mm],
  ["100.0.mm", 100.0.mm],
  ["100.to_f.mm", 100.to_f.mm],
  ["100.to_l", 100.to_l]
]

methods.each do |name, length|
  puts "  #{name}: #{length} (#{length.class}) #{length.is_a?(Length) ? '✅' : '❌'}"
  if length.is_a?(Length)
    offset = length * 0.5
    puts "    偏移: #{offset} (#{offset.class}) #{offset.is_a?(Length) ? '✅' : '❌'}"
  end
end

puts "\n🎯 建议的最佳实践："
puts "1. 始终使用 thickness * 0.5 而不是 thickness / 2.0"
puts "2. 确保厚度值是Length类型: thickness.to_l"
puts "3. 如果乘法失败，使用: (thickness.to_mm / 2.0).mm"
puts "4. 添加类型检查: offset_distance.is_a?(Length)"

puts "\n✅ Length类型修复测试完成！" 