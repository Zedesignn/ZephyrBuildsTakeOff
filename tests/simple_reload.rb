# 简化重载脚本 - 兼容所有SketchUp版本
puts "🔄 简化重载 Zephyr Wall Tool..."
puts "=" * 50

begin
  # 1. 检查当前状态
  puts "\n🔍 检查当前状态..."
  if defined?(ZephyrWallTool)
    puts "  ✅ ZephyrWallTool 已加载"
    types_count = ZephyrWallTool.all_types.length rescue 0
    puts "  📊 当前有 #{types_count} 个墙体类型"
  else
    puts "  ❌ ZephyrWallTool 未加载"
  end

  # 2. 清理文件缓存
  puts "\n🗑️ 清理文件缓存..."
  removed_count = 0
  $LOADED_FEATURES.delete_if do |feature|
    if feature.include?('zephyr_wall_tool')
      puts "  移除缓存: #{File.basename(feature)}"
      removed_count += 1
      true
    else
      false
    end
  end
  puts "  共移除 #{removed_count} 个缓存文件"

  # 3. 垃圾回收
  puts "\n♻️ 执行垃圾回收..."
  GC.start

  # 4. 重新加载
  puts "\n📂 重新加载插件..."
  loader_file = '/Users/Z/Downloads/Zephyr Builds Take Off/zephyr_wall_tool/zephyr_wall_tool_loader.rb'
  
  if File.exist?(loader_file)
    load loader_file
    puts "✅ 插件重新加载成功"
    
    # 5. 验证加载结果
    if defined?(ZephyrWallTool)
      puts "✅ ZephyrWallTool 模块可用"
      
      # 测试基本功能
      types = ZephyrWallTool.all_types
      puts "📊 当前有 #{types.length} 个墙体类型"
      
      if types.length > 0
        puts "\n🧪 测试Length类型处理："
        first_type = types.first
        thickness = first_type[:thickness]
        puts "  墙体类型: #{first_type[:name]}"
        puts "  厚度: #{thickness} (#{thickness.class})"
        
        if thickness.is_a?(Length)
          offset_distance = thickness * 0.5
          puts "  偏移距离: #{offset_distance} (#{offset_distance.class})"
          
          if offset_distance.is_a?(Length)
            puts "  ✅ Length类型处理正确"
          else
            puts "  ⚠️ 需要类型转换"
          end
        end
      end
      
    else
      puts "❌ ZephyrWallTool 模块不可用"
      return false
    end
    
  else
    puts "❌ 找不到加载器文件"
    return false
  end

  puts "\n🎉 简化重载完成！"
  puts "\n💡 可用功能："
  puts "   ZephyrWallTool.manage_types        # 墙体类型管理"
  puts "   ZephyrWallTool.create_all_wall_tags # 创建Tags"
  puts "   ZephyrWallTool.generate_walls_from_tags # 生成墙体"
  
  puts "\n📝 注意："
  puts "   此脚本跳过了工具栏管理，适用于所有SketchUp版本"
  puts "   如需工具栏管理，请使用 safe_reload.rb（需要SketchUp 2019+）"
  
  true

rescue => e
  puts "❌ 重载失败: #{e.message}"
  puts "📍 错误位置: #{e.backtrace.first}"
  false
end 