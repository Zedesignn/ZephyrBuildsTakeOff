# 安全重载脚本 - 避免常量移除错误
puts "🔄 安全重载 Zephyr Wall Tool..."
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

  # 2. 清理工具栏（避免重复）
  puts "\n🧹 清理工具栏..."
  begin
    # 检查UI.toolbars方法是否存在
    if UI.respond_to?(:toolbars)
      zephyr_toolbars = UI.toolbars.select do |toolbar|
        toolbar.name.include?('Zephyr') || toolbar.name.include?('Wall')
      end
      
      if zephyr_toolbars.any?
        zephyr_toolbars.each do |toolbar|
          if toolbar.visible?
            toolbar.hide
            puts "  隐藏工具栏: #{toolbar.name}"
          end
        end
        puts "  清理了 #{zephyr_toolbars.length} 个工具栏"
      else
        puts "  没有找到Zephyr相关工具栏"
      end
    else
      puts "  ⚠️ 当前SketchUp版本不支持UI.toolbars，跳过工具栏清理"
    end
  rescue => e
    puts "  ⚠️ 工具栏清理失败: #{e.message}，继续执行其他步骤"
  end

  # 3. 清理文件缓存
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

  # 4. 垃圾回收
  puts "\n♻️ 执行垃圾回收..."
  GC.start

  # 5. 重新加载
  puts "\n📂 重新加载插件..."
  loader_file = '/Users/Z/Downloads/Zephyr Builds Take Off/zephyr_wall_tool/zephyr_wall_tool_loader.rb'
  
  if File.exist?(loader_file)
    load loader_file
    puts "✅ 插件重新加载成功"
    
    # 6. 验证加载结果
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

  puts "\n🎉 安全重载完成！"
  puts "\n💡 可用功能："
  puts "   ZephyrWallTool.manage_types        # 墙体类型管理"
  puts "   ZephyrWallTool.create_all_wall_tags # 创建Tags"
  puts "   ZephyrWallTool.generate_walls_from_tags # 生成墙体"
  
  true

rescue => e
  puts "❌ 重载失败: #{e.message}"
  puts "📍 错误位置: #{e.backtrace.first}"
  false
end 