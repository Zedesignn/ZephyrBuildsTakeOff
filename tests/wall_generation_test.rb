# 墙体生成测试脚本
puts "🧪 墙体生成测试脚本 v2.0"
puts "=" * 50

# 检查插件是否已加载
unless defined?(ZephyrWallTool)
  puts "❌ ZephyrWallTool 模块未加载"
  puts "💡 请先运行: load '/Users/Z/Downloads/Zephyr Builds Take Off/tests/test_reload.rb'"
  exit
end

# 测试墙体类型
puts "\n🔍 检查墙体类型..."
types = ZephyrWallTool.all_types
puts "📊 当前有 #{types.length} 个墙体类型"

if types.empty?
  puts "❌ 没有墙体类型，请先创建墙体类型"
  puts "💡 运行: ZephyrWallTool.manage_types"
  exit
end

# 测试Length类型处理
puts "\n🧪 测试Length类型处理..."
types.each_with_index do |wall_type, index|
  puts "\n墙体类型 #{index + 1}: #{wall_type[:name]}"
  thickness = wall_type[:thickness]
  puts "  原始厚度: #{thickness} (#{thickness.class})"
  
  # 测试偏移距离计算
  if thickness.is_a?(Length)
    offset_distance = thickness * 0.5
    puts "  偏移距离(乘法): #{offset_distance} (#{offset_distance.class})"
    
    if offset_distance.is_a?(Length)
      puts "  ✅ 偏移距离类型正确"
    else
      puts "  ❌ 偏移距离类型错误，需要修复"
      # 使用修复方法
      thickness_mm = thickness.to_mm
      offset_distance_fixed = (thickness_mm / 2.0).mm
      puts "  修复后: #{offset_distance_fixed} (#{offset_distance_fixed.class})"
    end
  else
    puts "  ⚠️ 厚度不是Length类型"
  end
end

# 测试墙体Tags
puts "\n🏷️ 检查墙体Tags..."
model = Sketchup.active_model
wall_tags = model.layers.select { |layer| layer.name.start_with?('ZephyrWall_') }

if wall_tags.empty?
  puts "❌ 没有墙体Tags，正在创建..."
  ZephyrWallTool.create_all_wall_tags
  puts "✅ 墙体Tags创建完成"
else
  puts "✅ 找到 #{wall_tags.length} 个墙体Tags"
  wall_tags.each do |tag|
    puts "  - #{tag.name}"
  end
end

# 检查是否有线段分配到墙体Tags
puts "\n📏 检查线段分配..."
has_edges = false
wall_tags.each do |tag|
  edges_on_tag = model.active_entities.select do |entity|
    entity.is_a?(Sketchup::Edge) && entity.layer == tag
  end
  
  if edges_on_tag.length > 0
    puts "✅ Tag #{tag.name} 上有 #{edges_on_tag.length} 条线段"
    has_edges = true
  else
    puts "ℹ️ Tag #{tag.name} 上没有线段"
  end
end

unless has_edges
  puts "\n💡 建议："
  puts "1. 在模型中绘制一些线段"
  puts "2. 将线段分配到对应的墙体Tag（如：ZephyrWall_默认墙体）"
  puts "3. 然后运行: ZephyrWallTool.generate_walls_from_tags"
  exit
end

# 测试墙体生成
puts "\n🏗️ 测试墙体生成..."
begin
  ZephyrWallTool.generate_walls_from_tags
  puts "✅ 墙体生成测试完成"
rescue => e
  puts "❌ 墙体生成失败: #{e.message}"
  puts "📍 错误位置: #{e.backtrace.first}"
end

puts "\n🎉 测试完成！"

puts ""
puts "💡 使用说明："
puts "   1. 先运行 ZephyrWallTool.manage_types 创建墙体类型"
puts "   2. 在模型中绘制线段"
puts "   3. 将线段分配到对应的墙体Tag"
puts "   4. 运行 ZephyrWallTool.generate_walls_from_tags 生成墙体"
puts ""
puts "⚠️ 注意事项："
puts "   - 避免绘制垂直线段（仅在Z轴方向）"
puts "   - 确保线段有足够的长度（>1mm）"
puts "   - 线段应该在水平面（XY平面）内"
puts ""
puts "🎯 快速命令："
puts "ZephyrWallTool.manage_types           # 管理墙体类型"
puts "ZephyrWallTool.create_all_wall_tags   # 创建墙体Tags"
puts "ZephyrWallTool.generate_walls_from_tags # 从Tags生成墙体" 