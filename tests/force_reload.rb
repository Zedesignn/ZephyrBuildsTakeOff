# 强制重载脚本 - 确保加载最新的Length修复代码
puts "🚀 强制重载 Zephyr Wall Tool (Length强制修复版本)..."
puts "=" * 60

begin
  # 1. 强制清理所有相关常量和模块
  puts "🧹 强制清理所有相关常量..."
  
  # 清理主要常量
  if defined?(ZephyrWallTool)
    Object.send(:remove_const, :ZephyrWallTool)
    puts "  清理常量: ZephyrWallTool"
  end
  
  if defined?(ZephyrWallToolLoader)
    Object.send(:remove_const, :ZephyrWallToolLoader)
    puts "  清理常量: ZephyrWallToolLoader"
  end
  
  # 清理可能的子常量 - 使用安全检查
  [:RecoveryHelper, :OperationManager, :WallConnectionAnalyzer, 
   :WallConnectionProcessor, :MaterialLibraryManager, :WallDrawingTool,
   :UIRefreshManager, :MemoryManager].each do |const_name|
    begin
      if Object.const_defined?(const_name)
        Object.send(:remove_const, const_name)
        puts "  清理常量: #{const_name}"
      end
    rescue NameError => e
      # 忽略不存在的常量
      puts "  跳过不存在的常量: #{const_name}"
    end
  end
  
  # 2. 清理加载的文件缓存
  puts "🗑️ 清理文件加载缓存..."
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
  
  # 3. 强制垃圾回收
  puts "♻️ 执行垃圾回收..."
  3.times { GC.start }
  
  # 4. 等待一下确保清理完成
  sleep(0.1)
  
  # 5. 重新加载
  puts "📂 重新加载插件..."
  loader_file = '/Users/Z/Downloads/Zephyr Builds Take Off/zephyr_wall_tool/zephyr_wall_tool_loader.rb'
  
  if File.exist?(loader_file)
    # 强制重新读取文件
    load loader_file
    puts "✅ 加载器文件重新加载成功"
    
    # 6. 初始化
    if defined?(ZephyrWallToolLoader)
      ZephyrWallToolLoader.initialize_plugin
      puts "✅ 插件初始化完成"
    else
      puts "❌ ZephyrWallToolLoader 未定义"
      return false
    end
    
    # 7. 验证修复
    if defined?(ZephyrWallTool)
      puts "✅ ZephyrWallTool 模块可用"
      
      # 验证代码版本
      puts "\n🔍 验证代码版本和修复："
      
      # 检查是否有强制Length转换的代码
      core_file = '/Users/Z/Downloads/Zephyr Builds Take Off/zephyr_wall_tool/core.rb'
      if File.exist?(core_file)
        core_content = File.read(core_file)
        if core_content.include?('强制确保偏移距离是Length类型')
          puts "✅ 检测到强制Length转换代码"
        else
          puts "⚠️ 未检测到强制Length转换代码"
        end
        
        if core_content.include?('thickness * 0.5')
          puts "✅ 检测到乘法计算代码"
        else
          puts "⚠️ 未检测到乘法计算代码"
        end
      end
      
      # 测试墙体类型
      types = ZephyrWallTool.all_types
      puts "\n📊 当前有 #{types.length} 个墙体类型"
      
      if types.length > 0
        puts "\n🧪 测试Length类型处理："
        first_type = types.first
        thickness = first_type[:thickness]
        puts "  墙体类型: #{first_type[:name]}"
        puts "  厚度: #{thickness} (#{thickness.class})"
        
        # 模拟偏移距离计算
        if thickness.is_a?(Length)
          offset_distance = thickness * 0.5
          puts "  偏移距离(乘法): #{offset_distance} (#{offset_distance.class})"
          
          # 强制转换测试
          unless offset_distance.is_a?(Length)
            puts "  ⚠️ 需要强制转换"
            offset_distance = offset_distance.to_l
            puts "  转换后: #{offset_distance} (#{offset_distance.class})"
          end
          
          if offset_distance.is_a?(Length)
            puts "  ✅ 偏移距离类型正确"
          else
            puts "  ❌ 偏移距离类型仍然错误"
          end
        else
          puts "  ⚠️ 厚度不是Length类型"
        end
      end
      
    else
      puts "❌ ZephyrWallTool 模块不可用"
      return false
    end
    
  else
    puts "❌ 找不到加载器文件: #{loader_file}"
    return false
  end
  
  puts "\n🎉 强制重载完成！"
  puts "\n💡 现在可以测试墙体生成："
  puts "   ZephyrWallTool.generate_walls_from_tags"
  puts "\n🔧 如果仍有问题，请检查："
  puts "   1. 是否安装了最新的插件包"
  puts "   2. 是否重启了SketchUp"
  puts "   3. 线段是否正确分配到墙体Tag"
  
  true
  
rescue => e
  puts "❌ 强制重载失败: #{e.message}"
  puts "📍 错误位置: #{e.backtrace.first}"
  false
end 