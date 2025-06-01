puts "DEBUG: Loading zephyr_wall_tool.rb - Top of file"
# frozen_string_literal: true

# Zephyr Wall Tool Extension Loader
# 当Extension被启用时，加载主功能

require 'sketchup'

# 插件信息模块
module ZephyrWallToolLoader
  PLUGIN_NAME = 'Zephyr Wall Tool'
  PLUGIN_VERSION = '3.2.2' # MODIFIED

  # 模块内部标记，避免全局常量
  @loaded = false

  def self.loaded?
    @loaded
  end

  def self.mark_as_loaded
    @loaded = true
  end

  # 创建菜单项
  def self.create_menu
    plugins_menu = UI.menu('Plugins')
    zephyr_menu = plugins_menu.add_submenu("#{PLUGIN_NAME} v#{PLUGIN_VERSION}")

    add_basic_features_menu(zephyr_menu)
    add_connection_management_menu(zephyr_menu)
    add_material_management_menu(zephyr_menu)
    add_tag_workflow_menu(zephyr_menu)
    add_statistics_menu(zephyr_menu)
    add_native_data_menu(zephyr_menu)
    add_testing_menu(zephyr_menu)
    add_diagnostics_menu(zephyr_menu)

    puts "✅ #{PLUGIN_NAME} 菜单已创建"
  end

  # --- Menu Helper Methods (Private) ---
  class << self
    private

    def add_basic_features_menu(parent_menu)
      parent_menu.add_item('墙体类型管理器') { ZephyrWallTool.manage_types }
      parent_menu.add_separator
    end

    def add_connection_management_menu(parent_menu)
      menu = parent_menu.add_submenu('🔗 智能连接管理')
      menu.add_item('🔍 分析墙体连接') { ZephyrWallTool.analyze_wall_connections }
      menu.add_item('🔧 处理墙体连接') { ZephyrWallTool.process_wall_connections }
      menu.add_item('📊 连接管理器') { ZephyrWallTool.show_connection_manager }
      parent_menu.add_separator
    end

    def add_material_management_menu(parent_menu)
      menu = parent_menu.add_submenu('🎨 高级材质管理')
      menu.add_item('🎨 材质库管理器') { ZephyrWallTool.show_material_library }
      menu.add_item('🤖 智能材质推荐') do
        wall_types = ZephyrWallTool.all_types
        if wall_types.any?
          ZephyrWallTool.recommend_materials_for_wall_type(wall_types.first)
        else
          UI.messagebox('请先创建墙体类型', MB_OK, '智能材质推荐')
        end
      end
      menu.add_separator
      menu.add_item('📤 导出材质库') { ZephyrWallTool.export_material_library }
      menu.add_item('📥 导入材质库') { ZephyrWallTool.import_material_library }
      parent_menu.add_separator
    end

    def add_tag_workflow_menu(parent_menu)
      parent_menu.add_item('创建墙体Tags') { ZephyrWallTool.create_all_wall_tags }
      parent_menu.add_item('从Tags生成墙体') { ZephyrWallTool.generate_walls_from_tags }
      parent_menu.add_separator
    end

    def add_statistics_menu(parent_menu)
      parent_menu.add_item('墙体统计报告') { ZephyrWallTool.show_wall_statistics }
      parent_menu.add_item('增强统计报告 (Entity Info)') { ZephyrWallTool.show_enhanced_wall_statistics }
      parent_menu.add_separator
    end

    def add_native_data_menu(parent_menu)
      parent_menu.add_item('🔍 原生数据对比分析') { ZephyrWallTool.show_native_vs_plugin_statistics }
      parent_menu.add_item('📏 使用原生数据更新选中墙体') { ZephyrWallTool.update_wall_with_native_data }
      parent_menu.add_item('📦 批量更新所有墙体(原生数据)') { ZephyrWallTool.batch_update_walls_with_native_data }
      parent_menu.add_separator
    end

    def add_testing_menu(parent_menu)
      parent_menu.add_item('🧪 测试Z=0修复') { ZephyrWallTool.test_z0_fix_and_length_calculation }
      parent_menu.add_separator
    end

    def add_diagnostics_menu(parent_menu)
      parent_menu.add_item('图层状态诊断') { ZephyrWallTool.diagnose_layer_status }
      parent_menu.add_item('图层切换问题诊断') { ZephyrWallTool.diagnose_layer_switching_issue }
      # No separator after the last group
    end
  end
  # --- End Menu Helper Methods ---

  # 创建工具栏
  def self.create_toolbar
    cleanup_existing_toolbars
    toolbar = UI::Toolbar.new('Zephyr Wall Tool v3.2')

    add_main_toolbar_buttons(toolbar)
    add_quick_action_toolbar_buttons(toolbar)

    toolbar.show
    puts "✅ #{PLUGIN_NAME} 工具栏已创建"
    @@zephyr_toolbar = toolbar # 存储工具栏引用
    toolbar
  end

  # --- Toolbar Helper Methods (Private) ---
  class << self
    private

    def add_main_toolbar_buttons(toolbar)
      # 主要功能按钮 - 墙体类型管理器
      cmd_manage = create_toolbar_command('墙体类型管理器',
                                          '打开墙体类型管理器',
                                          '管理墙体类型、创建Tags、生成墙体') do
        ZephyrWallTool.manage_types
      end
      set_command_icons(cmd_manage, 'wall')
      toolbar.add_item(cmd_manage)

      # 连接分析按钮
      cmd_connections = create_toolbar_command('连接分析',
                                               '分析墙体连接关系',
                                               '智能分析墙体之间的连接关系') do
        ZephyrWallTool.analyze_wall_connections
      end
      toolbar.add_item(cmd_connections)

      # 材质库按钮
      cmd_materials = create_toolbar_command('材质库',
                                             '打开材质库管理器',
                                             '管理和应用墙体材质') do
        ZephyrWallTool.show_material_library
      end
      toolbar.add_item(cmd_materials)
    end

    def add_quick_action_toolbar_buttons(toolbar)
      # 快速功能按钮 - 创建Tags
      cmd_tags = create_toolbar_command('创建Tags',
                                        '为所有墙体类型创建Tags',
                                        '创建墙体Tags用于组织绘制') do
        ZephyrWallTool.create_all_wall_tags
      end
      toolbar.add_item(cmd_tags)

      # 生成墙体按钮
      cmd_generate = create_toolbar_command('生成墙体',
                                            '从Tags上的线段生成墙体',
                                            '根据Tag上的线段生成3D墙体') do
        ZephyrWallTool.generate_walls_from_tags
      end
      toolbar.add_item(cmd_generate)

      # 统计按钮
      cmd_stats = create_toolbar_command('统计',
                                         '显示墙体统计报告',
                                         '查看墙体数量、面积、体积统计') do
        ZephyrWallTool.show_wall_statistics
      end
      toolbar.add_item(cmd_stats)
    end

    def create_toolbar_command(label, tooltip, status_bar_text, &block)
      cmd = UI::Command.new(label, &block)
      cmd.tooltip = tooltip
      cmd.status_bar_text = status_bar_text
      cmd
    end

    def set_command_icons(command, base_icon_name)
      # __FILE__ is /Users/Z/Downloads/Zephyr Builds Take Off/zephyr_wall_tool.rb
      # plugin_root_dir will be /Users/Z/Downloads/Zephyr Builds Take Off
      plugin_root_dir = File.dirname(__FILE__)
      # Icons are in zephyr_wall_tool/images relative to the plugin_root_dir
      icon_dir = File.join(plugin_root_dir, 'zephyr_wall_tool', 'images')
      small_icon_path = File.join(icon_dir, "#{base_icon_name}_16.png")
      large_icon_path = File.join(icon_dir, "#{base_icon_name}_24.png")

      command.small_icon = small_icon_path if File.exist?(small_icon_path)
      command.large_icon = large_icon_path if File.exist?(large_icon_path)
    rescue StandardError => e
      puts "⚠️ 未找到图标文件 for #{base_icon_name}: #{e.message}"
    end
  end
  # --- End Toolbar Helper Methods ---

  # 🆕 清理现有工具栏的方法
  def self.cleanup_existing_toolbars
    puts '🧹 清理现有的Zephyr工具栏...'

    begin
    puts "DEBUG: Entering registration block."
      # 检查UI.toolbars方法是否存在
      if UI.respond_to?(:toolbars)
        # 查找并隐藏所有相关工具栏
        UI.toolbars.each do |toolbar|
          next unless toolbar.name.include?('Zephyr') || toolbar.name.include?('Wall')

          begin
    puts "DEBUG: Entering registration block."
            if toolbar.visible?
              toolbar.hide
              puts "  ✅ 隐藏工具栏: #{toolbar.name}"
            end
          rescue StandardError => e
            puts "  ⚠️ 隐藏工具栏失败: #{toolbar.name} - #{e.message}"
          end
        end
      else
        puts '  ⚠️ 当前SketchUp版本不支持UI.toolbars，跳过工具栏清理'
      end
    rescue StandardError => e
      puts "  ⚠️ 工具栏清理失败: #{e.message}"
    end

    # 清理类变量引用
    if defined?(@@zephyr_toolbar)
      @@zephyr_toolbar = nil
      puts '  ✅ 清理工具栏引用'
    end

    # 强制垃圾回收
    GC.start
    puts '  ✅ 执行垃圾回收'
  end

  # 🆕 安全的工具栏重置方法
  def self.reset_toolbar
    puts '🔄 重置Zephyr工具栏...'
    cleanup_existing_toolbars
    sleep(0.1) # 短暂延迟确保清理完成
    create_toolbar
    puts '✅ 工具栏重置完成'
  end

  # 🆕 检查工具栏状态的方法
  def self.check_toolbar_status
    puts '📊 工具栏状态检查：'

    begin
    puts "DEBUG: Entering registration block."
      if UI.respond_to?(:toolbars)
        zephyr_toolbars = UI.toolbars.select do |toolbar|
          toolbar.name.include?('Zephyr') || toolbar.name.include?('Wall')
        end

        if zephyr_toolbars.empty?
          puts '  ✅ 没有找到Zephyr相关工具栏'
        else
          puts "  找到 #{zephyr_toolbars.length} 个相关工具栏："
          zephyr_toolbars.each_with_index do |toolbar, index|
            puts "    #{index + 1}. #{toolbar.name} (可见: #{toolbar.visible?})"
          end
        end
      else
        puts '  ⚠️ 当前SketchUp版本不支持UI.toolbars'
      end
    rescue StandardError => e
      puts "  ❌ 工具栏状态检查失败: #{e.message}"
    end

    # 检查类变量状态
    if defined?(@@zephyr_toolbar) && @@zephyr_toolbar
      puts "  📌 类变量引用存在: #{@@zephyr_toolbar.name}"
    else
      puts '  📌 类变量引用为空'
    end
  end

  # 初始化插件
  def self.initialize_plugin
    puts "🚀 初始化 #{PLUGIN_NAME} v#{PLUGIN_VERSION}..."

    # Since this file (zephyr_wall_tool.rb) is now in the root of the plugin package (e.g., Plugins/zephyr_wall_tool.rb)
    # and core.rb is in Plugins/zephyr_wall_tool/core.rb
    # We need to require 'zephyr_wall_tool/core.rb'
    require_relative 'zephyr_wall_tool/core'

    # 创建菜单
    create_menu

    # 创建工具栏
    create_toolbar

    # 显示欢迎信息
    puts "✅ #{PLUGIN_NAME} v#{PLUGIN_VERSION} 加载完成!"
    puts "📍 菜单位置: 插件 > #{PLUGIN_NAME} v#{PLUGIN_VERSION}"
    puts '🔧 工具栏: Zephyr Wall Tool v3.2'

    # 直接加载完成，不显示确认对话框
    puts "🎉 #{PLUGIN_NAME} v#{PLUGIN_VERSION} 已成功加载并可以使用！"

    true
  rescue StandardError => e
    puts "❌ #{PLUGIN_NAME} 初始化失败: #{e.message}"
    puts '错误堆栈:'
    puts e.backtrace.join("\n")

    UI.messagebox(
      "❌ #{PLUGIN_NAME} 加载失败！\n\n" \
      "错误信息: #{e.message}\n\n" \
      '请检查Ruby控制台获取详细信息。',
      MB_OK,
      '加载错误'
    )

    false
  end
end # End of ZephyrWallToolLoader module

# This block ensures the extension is registered and initialized only once.
puts "DEBUG: Checking if ZephyrWallToolLoader is already loaded. Current loaded status: #{ZephyrWallToolLoader.loaded? rescue 'Error checking loaded status'}"
unless ZephyrWallToolLoader.loaded?
  begin
    puts "DEBUG: Entering registration block."
    # Define the extension
    # The loader file is this file itself, relative to the Plugins directory.
    extension_loader_path = File.basename(__FILE__)
    puts "DEBUG: extension_loader_path set to: #{extension_loader_path}"
    puts "DEBUG: Preparing to create SketchupExtension object with PLUGIN_NAME: '#{ZephyrWallToolLoader::PLUGIN_NAME}' and loader_path: '#{extension_loader_path}'"
    extension = SketchupExtension.new(ZephyrWallToolLoader::PLUGIN_NAME, extension_loader_path)

    extension.description = "Zephyr Wall Tool - Advanced wall creation and management for SketchUp. Version #{ZephyrWallToolLoader::PLUGIN_VERSION}."
    extension.version     = ZephyrWallToolLoader::PLUGIN_VERSION
    extension.creator     = "Zephyr Developer" # Replace with actual
    extension.copyright   = "#{Time.now.year}, Zephyr Developer. All rights reserved." # Replace with actual

    # Register the extension with SketchUp.
    # The 'true' argument tells SketchUp to load the extension immediately if enabled.
    puts "DEBUG: SketchupExtension object created. Preparing to register extension."
    Sketchup.register_extension(extension, true)
    puts "DEBUG: Sketchup.register_extension called."

    # If registration is successful and SketchUp loads this file (due to 'true' above or on next SU start),
    # the following initialization code will run.
    # We call initialize_plugin here, which loads core.rb and creates UI.
    puts "DEBUG: Attempting to initialize plugin after registration."
    if ZephyrWallToolLoader.initialize_plugin
      ZephyrWallToolLoader.mark_as_loaded # Mark as loaded only if initialization was successful
    else
      puts "Zephyr Wall Tool: Plugin initialization reported failure. Not marking as loaded."
    end

  rescue StandardError => e
    puts "Error during Zephyr Wall Tool extension registration or initial load: #{e.message}"
    puts e.backtrace.join("\n")
    UI.messagebox(
      "Critical error during Zephyr Wall Tool registration: #{e.message}. " \
      "The plugin may not function correctly. Check Ruby Console.",
      MB_OK,
      'Zephyr Wall Tool - Registration Error'
    )
  end
end
