<<<<<<< HEAD
# frozen_string_literal: true

require 'sketchup'
require 'json'
require 'cgi'

# 引入优化模块 - 暂时注释掉，因为lib目录不存在
# require_relative 'lib/zephyr_wall_tool_types'
# require_relative 'lib/zephyr_wall_tool_performance'
# require_relative 'lib/zephyr_wall_tool_error_handling'
# require_relative 'lib/zephyr_wall_tool_operations'
# require_relative 'lib/zephyr_wall_tool_connections'
# require_relative 'lib/zephyr_wall_tool_materials'

# Zephyr Wall Tool 主模块 - 统一命名空间
module ZephyrWallTool
  # 简化的类定义来替代缺失的模块
  class RecoveryHelper
    def self.with_recovery(operation_name:)
      yield
    rescue StandardError => e
      puts "❌ #{operation_name} 失败: #{e.message}"
      puts "错误详情: #{e.backtrace.first(3).join("\n")}"
    end
  end

  class OperationManager
    def initialize
      puts 'OperationManager 已初始化'
    end

    def execute_batch_operation(operation_name, items)
      puts "执行批量操作: #{operation_name}"
      items.each_with_index do |item, index|
        puts "  处理项目 #{index + 1}/#{items.length}: #{item}"
        yield(item) if block_given?
      end
    end
  end

  class WallConnectionAnalyzer
    def initialize(wall_groups)
      @wall_groups = wall_groups
      puts "WallConnectionAnalyzer 已初始化，墙体数量: #{wall_groups.length}"
    end

    def analyze_connections
      puts '分析墙体连接...'
      # 简化实现
      []
    end

    def connections_summary
      '连接分析完成'
    end
  end

  class WallConnectionProcessor
    def initialize(analyzer)
      @analyzer = analyzer
      puts 'WallConnectionProcessor 已初始化'
    end

    def process_connections(options = {})
      puts "处理墙体连接，选项: #{options}"
      { processed: 0, failed: 0 }
    end
  end

  class MaterialLibraryManager
    def initialize
      puts 'MaterialLibraryManager 已初始化'
    end

    def custom_materials
      {}
    end

    def recommended_materials
      []
    end

    def apply_material_to_wall(_wall_group, material_config)
      puts "应用材质到墙体: #{material_config[:name]}"
    end
  end

  class WallDrawingTool
    def initialize
      puts 'WallDrawingTool 已初始化'
    end

    def wall_type=(wall_type)
      @current_wall_type = wall_type
      puts "设置墙体类型: #{wall_type[:name]}"
    end
  end

  class UIRefreshManager
    def self.refresh_ui
      puts '刷新UI'
    end

    # 添加缺少的request_refresh方法
    def self.request_refresh(options = {})
      force = options[:force] || false
      delay = options[:delay] || 0.0

      puts "🔄 请求UI刷新 (force: #{force}, delay: #{delay})"

      if delay.positive?
        # 延迟刷新
        UI.start_timer(delay, false) do
          refresh_ui
          Sketchup.active_model.active_view.invalidate if force
        end
      else
        # 立即刷新
        refresh_ui
        Sketchup.active_model.active_view.invalidate if force
      end
    end
  end

  class MemoryManager
    def self.with_memory_optimization(options = {})
      puts "启用内存优化: #{options}"
      yield if block_given?
    end
  end

  TYPE_DICT = 'WallTypes'
  DEFAULT_TYPES = [
    { name: '默认墙体', color: 'Red', thickness: 200.mm, height: 2800.mm, tag: '标准墙' }
  ].freeze

  # 全局墙体绘制工具实例
  @wall_drawing_tool = nil

  # 全局操作管理器实例
  @operation_manager = nil

  # 全局连接分析器实例
  @connection_analyzer = nil

  # 全局材质库管理器实例
  @material_library_manager = nil

  # 获取操作管理器
  # @return [OperationManager] 操作管理器实例
  def self.operation_manager
    @operation_manager ||= OperationManager.new
  end

  # 获取连接分析器
  # @return [WallConnectionAnalyzer] 连接分析器实例
  def self.connection_analyzer
    wall_groups = find_all_wall_groups(Sketchup.active_model.active_entities)
    @connection_analyzer = WallConnectionAnalyzer.new(wall_groups)
  end

  # 获取材质库管理器
  # @return [MaterialLibraryManager] 材质库管理器实例
  def self.material_library_manager
    @material_library_manager ||= MaterialLibraryManager.new
  end

  # 获取或创建墙体绘制工具
  # @return [WallDrawingTool] 墙体绘制工具实例
  def self.wall_drawing_tool
    @wall_drawing_tool ||= WallDrawingTool.new
    @wall_drawing_tool
  end

  # 启动墙体绘制
  # @param wall_type [Hash] 墙体类型配置
  # @return [void]
  def self.start_wall_drawing(wall_type)
    RecoveryHelper.with_recovery(operation_name: '启动墙体绘制') do
      drawing_tool = wall_drawing_tool
      drawing_tool.wall_type = wall_type
      drawing_tool.start_drawing
    end
  end

  # 分析墙体连接
  # @return [void]
  def self.analyze_wall_connections
    RecoveryHelper.with_recovery(operation_name: '分析墙体连接') do
      analyzer = connection_analyzer

      if analyzer.wall_groups.empty?
        UI.messagebox('模型中没有找到墙体，请先创建一些墙体。', MB_OK, '连接分析')
        return
      end

      puts '🔍 开始墙体连接分析...'

      # 执行分析
      analyzer.analyze_connections

      # 显示分析报告
      analyzer.show_connection_report

      puts '✅ 连接分析完成'
    end
  end

  # 处理墙体连接
  # @param options [Hash] 处理选项
  # @return [void]
  def self.process_wall_connections(options = {})
    RecoveryHelper.with_recovery(operation_name: '处理墙体连接') do
      analyzer = connection_analyzer

      if analyzer.wall_groups.empty?
        UI.messagebox('模型中没有找到墙体，请先创建一些墙体。', MB_OK, '连接处理')
        return
      end

      # 创建连接处理器
      processor = WallConnectionProcessor.new(analyzer)

      puts '🔧 开始处理墙体连接...'

      # 执行处理
      results = processor.process_all_connections(options)

      # 显示处理报告
      if results[:message]
        UI.messagebox(results[:message], MB_OK, '连接处理')
      else
        processor.show_processing_report(results)
      end

      puts '✅ 连接处理完成'
    end
  end

  # 显示连接管理对话框
  # @return [void]
  def self.show_connection_manager
    RecoveryHelper.with_recovery(operation_name: '显示连接管理器') do
      analyzer = connection_analyzer

      if analyzer.wall_groups.empty?
        UI.messagebox('模型中没有找到墙体，请先创建一些墙体。', MB_OK, '连接管理')
        return
      end

      # 创建连接管理对话框
      create_connection_manager_dialog(analyzer)
    end
  end

  # 显示材质库管理对话框
  # @return [void]
  def self.show_material_library
    RecoveryHelper.with_recovery(operation_name: '显示材质库管理器') do
      manager = material_library_manager
      manager.create_material_selector_dialog

      puts '🎨 材质库管理器已打开'
    end
  end

  # 智能材质推荐
  # @param wall_type [Hash] 墙体类型
  # @return [void]
  def self.recommend_materials_for_wall_type(wall_type)
    RecoveryHelper.with_recovery(operation_name: '智能材质推荐') do
      manager = material_library_manager
      recommendations = manager.recommend_materials(wall_type)

      if recommendations.empty?
        UI.messagebox('没有找到适合的材质推荐', MB_OK, '材质推荐')
        return
      end

      # 创建推荐对话框
      create_material_recommendation_dialog(wall_type, recommendations)
    end
  end

  # 批量应用材质到墙体类型
  # @param wall_type_name [String] 墙体类型名称
  # @param material_config [Hash] 材质配置
  # @return [void]
  def self.apply_material_to_wall_type(wall_type_name, material_config)
    RecoveryHelper.with_recovery(operation_name: '批量应用材质到墙体类型') do
      wall_groups = find_all_wall_groups(Sketchup.active_model.active_entities)
      target_walls = wall_groups.select do |wall|
        wall.get_attribute('ZephyrWallData', 'wall_type_name') == wall_type_name
      end

      if target_walls.empty?
        UI.messagebox("没有找到类型为 '#{wall_type_name}' 的墙体", MB_OK, '材质应用')
        return
      end

      manager = material_library_manager
      results = manager.batch_apply_material(target_walls, material_config)

      message = "材质应用到 '#{wall_type_name}' 类型墙体完成:\n"
      message += "成功: #{results[:success]} 个墙体\n"
      message += "失败: #{results[:failed]} 个墙体" if results[:failed].positive?

      UI.messagebox(message, MB_OK, '材质应用结果')

      puts "✅ 材质已应用到墙体类型: #{wall_type_name}"
    end
  end

  # 导出材质库
  # @return [void]
  def self.export_material_library
    RecoveryHelper.with_recovery(operation_name: '导出材质库') do
      file_path = UI.savepanel('导出材质库', '', 'zephyr_materials.json')
      return unless file_path

      manager = material_library_manager
      if manager.export_material_library(file_path)
        UI.messagebox("材质库已成功导出到:\n#{file_path}", MB_OK, '导出成功')
      else
        UI.messagebox('导出失败，请检查文件路径和权限', MB_OK, '导出失败')
      end
    end
  end

  # 导入材质库
  # @return [void]
  def self.import_material_library
    RecoveryHelper.with_recovery(operation_name: '导入材质库') do
      file_path = UI.openpanel('导入材质库', '', 'JSON文件|*.json||')
      return unless file_path

      manager = material_library_manager
      if manager.import_material_library(file_path)
        UI.messagebox('材质库已成功导入', MB_OK, '导入成功')

        # 重新初始化管理器以加载新数据
        @material_library_manager = nil
      else
        UI.messagebox('导入失败，请检查文件格式', MB_OK, '导入失败')
      end
    end
  end

  def self.create_connection_manager_dialog(analyzer)
    html_content = generate_connection_manager_html(analyzer)

    dialog = UI::WebDialog.new('墙体连接管理', false, 'ConnectionManager', 600, 500)
    dialog.set_html(html_content)

    # 设置回调
    setup_connection_manager_callbacks(dialog, analyzer)

    dialog.show
  end

  # 生成连接管理器HTML
  # @param analyzer [WallConnectionAnalyzer] 连接分析器
  # @return [String] HTML内容
  def self.generate_connection_manager_html(analyzer)
    stats = analyzer.connection_statistics

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>墙体连接管理</title>
        <style>
          body {#{' '}
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;#{' '}
            margin: 0; padding: 20px; background: #f5f5f5;#{' '}
          }
          .header {#{' '}
            background: white; border-radius: 8px; padding: 20px; margin-bottom: 20px;#{' '}
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .stats-grid {#{' '}
            display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));#{' '}
            gap: 15px; margin-bottom: 20px;#{' '}
          }
          .stat-card {#{' '}
            background: white; border-radius: 8px; padding: 15px; text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .stat-value { font-size: 24px; font-weight: bold; color: #007AFF; }
          .stat-label { font-size: 12px; color: #666; margin-top: 5px; }
          .actions {#{' '}
            background: white; border-radius: 8px; padding: 20px;#{' '}
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .btn {#{' '}
            padding: 12px 20px; margin: 5px; border: none; border-radius: 6px;#{' '}
            cursor: pointer; font-weight: 500; transition: all 0.2s ease;
          }
          .btn-primary { background: #007AFF; color: white; }
          .btn-primary:hover { background: #0056CC; }
          .btn-secondary { background: #f0f0f0; color: #333; }
          .btn-secondary:hover { background: #e0e0e0; }
          .btn-success { background: #34C759; color: white; }
          .btn-success:hover { background: #28A745; }
          .connection-list {#{' '}
            background: white; border-radius: 8px; padding: 20px; margin-top: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-height: 300px; overflow-y: auto;
          }
          .connection-item {#{' '}
            padding: 10px; border-bottom: 1px solid #eee; display: flex;#{' '}
            justify-content: space-between; align-items: center;
          }
          .connection-item:last-child { border-bottom: none; }
          .connection-type { font-weight: 500; }
          .connection-quality { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
          .quality-excellent { background: #d4edda; color: #155724; }
          .quality-good { background: #cce5ff; color: #004085; }
          .quality-fair { background: #fff3cd; color: #856404; }
          .quality-poor { background: #f8d7da; color: #721c24; }
          .quality-critical { background: #f5c6cb; color: #721c24; }
        </style>
      </head>
      <body>
        <div class="header">
          <h2>🔗 墙体连接管理</h2>
          <p>智能分析和处理墙体之间的连接关系</p>
        </div>
      #{'  '}
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-value">#{stats[:total_walls]}</div>
            <div class="stat-label">墙体总数</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">#{stats[:total_connections]}</div>
            <div class="stat-label">连接总数</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">#{(stats[:connection_rate] * 100).round(1)}%</div>
            <div class="stat-label">连接率</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">#{stats[:average_angle].round(1)}°</div>
            <div class="stat-label">平均角度</div>
          </div>
        </div>
      #{'  '}
        <div class="actions">
          <h3>操作选项</h3>
          <button class="btn btn-primary" onclick="analyzeConnections()">🔍 重新分析连接</button>
          <button class="btn btn-success" onclick="processConnections()">🔧 处理所有连接</button>
          <button class="btn btn-secondary" onclick="showDetailedReport()">📊 详细报告</button>
          <button class="btn btn-secondary" onclick="exportConnections()">📤 导出连接数据</button>
        </div>
      #{'  '}
        <div class="connection-list" id="connectionList">
          <h3>连接列表</h3>
          <div id="connections">
            <!-- 连接项目将通过JavaScript动态加载 -->
          </div>
        </div>
      #{'  '}
        <script>
          function analyzeConnections() {
            window.location = 'skp:analyze_connections';
          }
      #{'    '}
          function processConnections() {
            if (confirm('确定要处理所有连接吗？这将修改墙体几何。')) {
              window.location = 'skp:process_connections';
            }
          }
      #{'    '}
          function showDetailedReport() {
            window.location = 'skp:show_detailed_report';
          }
      #{'    '}
          function exportConnections() {
            window.location = 'skp:export_connections';
          }
      #{'    '}
          function loadConnections() {
            window.location = 'skp:load_connections';
          }
      #{'    '}
          // 初始化
          loadConnections();
        </script>
      </body>
      </html>
    HTML
  end

  # 设置连接管理器回调
  # @param dialog [UI::WebDialog] 对话框
  # @param analyzer [WallConnectionAnalyzer] 连接分析器
  # @return [void]
  def self.setup_connection_manager_callbacks(dialog, analyzer)
    dialog.add_action_callback('analyze_connections') do |web_dialog, _action_name|
      analyze_wall_connections
      # 刷新对话框
      web_dialog.execute_script('location.reload();')
    end

    dialog.add_action_callback('process_connections') do |web_dialog, _action_name|
      process_wall_connections
      # 刷新对话框
      web_dialog.execute_script('location.reload();')
    end

    dialog.add_action_callback('show_detailed_report') do |_web_dialog, _action_name|
      analyzer.show_connection_report
    end

    dialog.add_action_callback('export_connections') do |_web_dialog, _action_name|
      export_connection_data(analyzer)
    end

    dialog.add_action_callback('load_connections') do |web_dialog, _action_name|
      connections_html = generate_connections_list_html(analyzer)
      escaped_html = connections_html.gsub("'", "\\'").gsub("\n", '\\n')
      web_dialog.execute_script("document.getElementById('connections').innerHTML = '#{escaped_html}';")
    end
  end

  # 生成连接列表HTML
  # @param analyzer [WallConnectionAnalyzer] 连接分析器
  # @return [String] 连接列表HTML
  def self.generate_connections_list_html(analyzer)
    results = analyzer.analyze_connections
    connections = results[:all_connections]

    return '<p>没有发现连接</p>' if connections.empty?

    html = ''
    connections.each_with_index do |connection, _index|
      quality_class = "quality-#{connection[:quality]}"
      type_display = analyzer.send(:format_connection_type, connection[:type])
      quality_display = analyzer.send(:format_quality_level, connection[:quality])

      html += <<~HTML
        <div class="connection-item">
          <div>
            <div class="connection-type">#{type_display}</div>
            <div style="font-size: 12px; color: #666;">
              #{connection[:wall1_name]} ↔ #{connection[:wall2_name]}
            </div>
          </div>
          <div>
            <span class="connection-quality #{quality_class}">#{quality_display}</span>
          </div>
        </div>
      HTML
    end

    html
  end

  # 导出连接数据
  # @param analyzer [WallConnectionAnalyzer] 连接分析器
  # @return [void]
  def self.export_connection_data(analyzer)
    RecoveryHelper.with_recovery(operation_name: '导出连接数据') do
      results = analyzer.analyze_connections

      file_path = UI.savepanel('保存连接数据', '', '墙体连接数据.json')
      return unless file_path

      # 准备导出数据
      export_data = {
        analysis_info: {
          total_walls: results[:total_walls],
          total_connections: results[:total_connections],
          analysis_time: results[:analysis_time],
          analyzed_at: Time.now.to_s
        },
        connections: results[:all_connections].map do |conn|
          {
            wall1_name: conn[:wall1_name],
            wall2_name: conn[:wall2_name],
            type: conn[:type],
            angle: conn[:angle],
            quality: conn[:quality],
            distance: conn[:distance]
          }
        end
      }

      File.write(file_path, JSON.pretty_generate(export_data))
      UI.messagebox("连接数据已导出到:\n#{file_path}", MB_OK, '导出成功')

      puts "✅ 连接数据已导出: #{file_path}"
    end
  end

  # 获取所有类型
  # @return [Array<Hash>] 墙体类型数组
  def self.all_types
    model = Sketchup.active_model

    # 检查是否有旧格式数据，如果有则清理
    old_data = model.get_attribute(TYPE_DICT, 'types')
    if old_data
      puts 'Found old data format, clearing...'
      clear_old_data
    end

    # 获取类型数量
    type_count = model.get_attribute(TYPE_DICT, 'count', 0)
    puts "Found #{type_count} types in model"

    types = []

    if type_count.zero?
      puts 'No types found, creating default type'
      # 创建默认类型
      default_type = {
        name: '默认墙体',
        color: 'Red',
        thickness: 200.0.mm,
        height: 2800.0.mm,
        tag: '标准墙'
      }
      save_single_type(0, default_type)
      model.set_attribute(TYPE_DICT, 'count', 1)
      types << default_type
    else
      # 读取每个类型
      (0...type_count).each do |i|
        type = load_single_type(i)
        if type
          types << type
          puts "Loaded type #{i}: #{type[:name]}"
        else
          puts "Failed to load type #{i}"
        end
      end
    end

    puts "Returning #{types.length} types"
    types
  end

  # 保存单个类型
<<<<<<< HEAD
  # @param index [Integer] 类型索引
  # @param type [Hash] 墙体类型数据
  # @return [void]
  def self.save_single_type(index, type)
    model = Sketchup.active_model
    prefix = "type_#{index}_"

=======
  def self.save_single_type(index, type)
    model = Sketchup.active_model
    prefix = "type_#{index}_"
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    # 分别保存每个属性，确保单位正确
    model.set_attribute(TYPE_DICT, "#{prefix}name", type[:name].to_s)
    model.set_attribute(TYPE_DICT, "#{prefix}color", type[:color].to_s)
    model.set_attribute(TYPE_DICT, "#{prefix}thickness_mm", type[:thickness].to_mm.to_f)  # 转换为毫米数值
    model.set_attribute(TYPE_DICT, "#{prefix}height_mm", type[:height].to_mm.to_f)        # 转换为毫米数值
    model.set_attribute(TYPE_DICT, "#{prefix}tag", type[:tag].to_s)

    puts "Saved type #{index}: #{type[:name]} (#{type[:thickness].to_mm}mm x #{type[:height].to_mm}mm)"
  end

  # 加载单个类型
<<<<<<< HEAD
  # @param index [Integer] 类型索引
  # @return [Hash, nil] 墙体类型数据或 nil
  def self.load_single_type(index)
    model = Sketchup.active_model
    prefix = "type_#{index}_"

    name = model.get_attribute(TYPE_DICT, "#{prefix}name")
    color = model.get_attribute(TYPE_DICT, "#{prefix}color")
    thickness_mm = model.get_attribute(TYPE_DICT, "#{prefix}thickness_mm")
    height_mm = model.get_attribute(TYPE_DICT, "#{prefix}height_mm")
    tag = model.get_attribute(TYPE_DICT, "#{prefix}tag")

=======
  def self.load_single_type(index)
    model = Sketchup.active_model
    prefix = "type_#{index}_"
    
    name = model.get_attribute(TYPE_DICT, "#{prefix}name")
    color = model.get_attribute(TYPE_DICT, "#{prefix}color") 
    thickness_mm = model.get_attribute(TYPE_DICT, "#{prefix}thickness_mm")
    height_mm = model.get_attribute(TYPE_DICT, "#{prefix}height_mm")
    tag = model.get_attribute(TYPE_DICT, "#{prefix}tag")
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    if name && color && thickness_mm && height_mm && tag
      {
        name: name,
        color: color,
        thickness: thickness_mm.to_f.mm,  # 从毫米数值创建Length对象
        height: height_mm.to_f.mm,        # 从毫米数值创建Length对象
        tag: tag
      }
    else
<<<<<<< HEAD
      missing_attrs = "name=#{name}, color=#{color}, thickness_mm=#{thickness_mm}, " \
                      "height_mm=#{height_mm}, tag=#{tag}"
      puts "Missing attributes for type #{index}: #{missing_attrs}"
=======
      puts "Missing attributes for type #{index}: name=#{name}, color=#{color}, thickness_mm=#{thickness_mm}, height_mm=#{height_mm}, tag=#{tag}"
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
      nil
    end
  end

<<<<<<< HEAD
  # 保存所有类型 - 使用官方 API 替代 delete_attribute
  # @param types [Array<Hash>] 墙体类型数组
  # @return [void]
  def self.save_types(types)
    model = Sketchup.active_model
    puts "Saving #{types.length} types using individual attributes"

    # 先清除旧数据 - 使用 set_attribute(dict, key, nil) 替代 delete_attribute
    old_count = model.get_attribute(TYPE_DICT, 'count', 0)
    (0...old_count).each do |i|
      prefix = "type_#{i}_"
      model.set_attribute(TYPE_DICT, "#{prefix}name", nil)
      model.set_attribute(TYPE_DICT, "#{prefix}color", nil)
      model.set_attribute(TYPE_DICT, "#{prefix}thickness_mm", nil)
      model.set_attribute(TYPE_DICT, "#{prefix}height_mm", nil)
      model.set_attribute(TYPE_DICT, "#{prefix}tag", nil)
    end

    # 保存新数据
    types.each_with_index do |type, index|
      save_single_type(index, type)
    end

=======
  # 保存所有类型
  def self.save_types(types)
    model = Sketchup.active_model
    puts "Saving #{types.length} types using individual attributes"
    
    # 先清除旧数据
    old_count = model.get_attribute(TYPE_DICT, 'count', 0)
    (0...old_count).each do |i|
      prefix = "type_#{i}_"
      model.delete_attribute(TYPE_DICT, "#{prefix}name")
      model.delete_attribute(TYPE_DICT, "#{prefix}color")
      model.delete_attribute(TYPE_DICT, "#{prefix}thickness_mm")
      model.delete_attribute(TYPE_DICT, "#{prefix}height_mm")
      model.delete_attribute(TYPE_DICT, "#{prefix}tag")
    end
    
    # 保存新数据
    types.each_with_index do |type, index|
      self.save_single_type(index, type)
    end
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    # 更新数量
    model.set_attribute(TYPE_DICT, 'count', types.length)
    puts "Saved #{types.length} types successfully"
  end

<<<<<<< HEAD
  # macOS 系统颜色选择器 - 修复假死问题
  def self.open_system_color_picker_macos
    puts '🎨 启动系统颜色选择器...'

    begin
      # 使用更安全的异步AppleScript调用
      script = <<~APPLESCRIPT
        try
          tell application "System Events"
            set chosenColor to choose color default color {32768, 32768, 32768}
            return chosenColor
          end tell
        on error
          return "cancelled"
        end try
      APPLESCRIPT

      # 使用超时机制防止假死
      require 'timeout'

      result = nil
      begin
        Timeout.timeout(10) do # 10秒超时
          puts '📞 调用AppleScript颜色选择器...'
          result = `osascript -e '#{script.gsub("'", "\\'")}' 2>/dev/null`.strip
          puts "📞 AppleScript返回: #{result}"
        end
      rescue Timeout::Error
        puts '⏰ 颜色选择器超时，使用备选方案'
        return open_sketchup_color_picker_fallback
      end

      # 处理用户取消的情况
      if result.nil? || result.empty? || result == 'false' || result == 'cancelled'
        puts '❌ 用户取消了颜色选择'
        return nil
      end

      # AppleScript返回的颜色格式是 {r, g, b}，范围是0-65535
      # 需要转换为0-255范围
      if result.match(/\{(\d+),\s*(\d+),\s*(\d+)\}/)
        r = (::Regexp.last_match(1).to_f / 65_535.0 * 255).round
        g = (::Regexp.last_match(2).to_f / 65_535.0 * 255).round
        b = (::Regexp.last_match(3).to_f / 65_535.0 * 255).round

        puts "✅ 颜色选择成功: RGB(#{r}, #{g}, #{b})"
        # 创建SketchUp颜色对象
        Sketchup::Color.new(r, g, b)
      else
        puts "❌ 无法解析颜色格式: #{result}"
        open_sketchup_color_picker_fallback
      end
    rescue StandardError => e
      puts "❌ 系统颜色选择器错误: #{e.message}"
      puts '🔄 切换到备选方案...'
      # 使用SketchUp内置的颜色选择器作为备选
      open_sketchup_color_picker_fallback
    end
  end

  def self.open_sketchup_color_picker_fallback
    # SketchUp内置颜色选择器备选方案
    puts '🎨 使用备选颜色选择器...'

    # 使用inputbox作为简单的颜色输入
    result = UI.inputbox(
      ['颜色 (十六进制，如 #FF0000):'],
      ['#808080'],
      '选择颜色'
    )

    if result && !result[0].empty?
      color_input = result[0].strip

      # 尝试解析颜色
      if color_input.match(/^#[0-9A-Fa-f]{6}$/)
        r = color_input[1..2].to_i(16)
        g = color_input[3..4].to_i(16)
        b = color_input[5..6].to_i(16)
        puts "✅ 解析十六进制颜色: RGB(#{r}, #{g}, #{b})"
        return Sketchup::Color.new(r, g, b)
      elsif color_input.match(/^#[0-9A-Fa-f]{3}$/)
        # 支持3位十六进制颜色
        r = (color_input[1] * 2).to_i(16)
        g = (color_input[2] * 2).to_i(16)
        b = (color_input[3] * 2).to_i(16)
        return Sketchup::Color.new(r, g, b)
      else
        # 尝试使用颜色名称
        return color_input
      end
    end

    nil
  rescue StandardError => e
    puts "备选颜色选择器错误: #{e.message}"
    nil
  end

  # macOS SketchUp 2024 专用方法：打开材质面板
  def self.open_materials_panel_macos
    success = false

=======
  # macOS SketchUp 2024 专用方法：打开材质面板
  def self.open_materials_panel_macos
    success = false
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    # macOS 专用方法1: 使用菜单触发
    begin
      # 尝试通过菜单系统打开材质窗口
      if defined?(UI.show_inspector)
<<<<<<< HEAD
        UI.show_inspector('Materials')
        success = true
        puts 'Materials panel opened via show_inspector'
      end
    rescue StandardError => e
      puts "show_inspector failed: #{e}"
    end

=======
        UI.show_inspector("Materials")
        success = true
        puts "Materials panel opened via show_inspector"
      end
    rescue => e
      puts "show_inspector failed: #{e}"
    end
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    # macOS 专用方法2: 使用Cocoa特定的action
    unless success
      begin
        # macOS SketchUp 2024的材质窗口action ID
<<<<<<< HEAD
        Sketchup.send_action(10_520)
        success = true
        puts 'Materials panel opened via send_action 10520'
      rescue StandardError => e
        puts "send_action 10520 failed: #{e}"
      end
    end

    # macOS 专用方法3: 尝试激活Paint Bucket工具
    unless success
      begin
        Sketchup.send_action('selectPaintTool:')
        success = true
        puts 'Paint bucket tool activated'
      rescue StandardError => e
        puts "selectPaintTool failed: #{e}"
      end
    end

    # 显示用户提示
    UI.messagebox("请手动打开材质面板：\n菜单 > 窗口 > 默认面板 > 材质") unless success

=======
        Sketchup.send_action(10520)
        success = true
        puts "Materials panel opened via send_action 10520"
      rescue => e
        puts "send_action 10520 failed: #{e}"
      end
    end
    
    # macOS 专用方法3: 尝试激活Paint Bucket工具
    unless success
      begin
        Sketchup.send_action("selectPaintTool:")
        success = true
        puts "Paint bucket tool activated"
      rescue => e
        puts "selectPaintTool failed: #{e}"
      end
    end
    
    # 显示用户提示
    unless success
      UI.messagebox("请手动打开材质面板：\n菜单 > 窗口 > 默认面板 > 材质")
    end
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    success
  end

  # macOS SketchUp 2024 专用方法：获取当前材质颜色
  def self.get_current_material_color_macos
    model = Sketchup.active_model
    found_color = nil
    debug_info = []
<<<<<<< HEAD

    # macOS 方法1: 检查materials.current
    begin
      current_material = model.materials.current
      if current_material&.color
        found_color = current_material.color
        debug_info << "✓ Found via materials.current: #{found_color}"
      else
        debug_info << '✗ materials.current is nil or has no color'
      end
    rescue StandardError => e
      debug_info << "✗ materials.current error: #{e.message}"
    end

=======
    
    # macOS 方法1: 检查materials.current
    begin
      current_material = model.materials.current
      if current_material && current_material.color
        found_color = current_material.color
        debug_info << "✓ Found via materials.current: #{found_color}"
      else
        debug_info << "✗ materials.current is nil or has no color"
      end
    rescue => e
      debug_info << "✗ materials.current error: #{e.message}"
    end
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    # macOS 方法2: 检查模型中是否有材质可选择
    unless found_color
      begin
        materials = model.materials
<<<<<<< HEAD
        if materials.length.positive?
=======
        if materials.length > 0
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
          debug_info << "✓ Found #{materials.length} materials in model"
          # 显示材质选择对话框
          material_names = materials.map(&:display_name)
          choice = UI.inputbox(
            ["选择材质 (输入序号 1-#{materials.length}):"],
<<<<<<< HEAD
            ['1'],
            "模型中的材质:\n#{material_names.each_with_index.map { |name, i| "#{i + 1}. #{name}" }.join("\n")}"
          )
          if choice && choice[0].to_i.positive? && choice[0].to_i <= materials.length
=======
            ["1"],
            "模型中的材质:\n#{material_names.each_with_index.map{|name, i| "#{i+1}. #{name}"}.join("\n")}"
          )
          if choice && choice[0].to_i > 0 && choice[0].to_i <= materials.length
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            selected_material = materials.to_a[choice[0].to_i - 1]
            found_color = selected_material.color
            debug_info << "✓ User selected material: #{selected_material.display_name}"
          else
<<<<<<< HEAD
            debug_info << '✗ User cancelled or invalid selection'
          end
        else
          debug_info << '✗ No materials in model'
        end
      rescue StandardError => e
        debug_info << "✗ Materials list error: #{e.message}"
      end
    end

    # macOS 方法3: 如果还是没有找到，给出使用说明
    unless found_color
      debug_info << "\n使用说明："
      debug_info << '1. 在材质面板中选择一个材质'
      debug_info << '2. 用油漆桶工具在模型中点击任意面'
      debug_info << "3. 再次点击'获取材质'按钮"
      debug_info << "\n或者使用预设颜色/自定义颜色"
    end

    puts debug_info.join("\n")
    [found_color, debug_info]
=======
            debug_info << "✗ User cancelled or invalid selection"
          end
        else
          debug_info << "✗ No materials in model"
        end
      rescue => e
        debug_info << "✗ Materials list error: #{e.message}"
      end
    end
    
    # macOS 方法3: 如果还是没有找到，给出使用说明
    unless found_color
      debug_info << "\n使用说明："
      debug_info << "1. 在材质面板中选择一个材质"
      debug_info << "2. 用油漆桶工具在模型中点击任意面"
      debug_info << "3. 再次点击'获取材质'按钮"
      debug_info << "\n或者使用预设颜色/自定义颜色"
    end
    
    puts debug_info.join("\n")
    return found_color, debug_info
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
  end

  # macOS SketchUp 2024 专用方法：创建测试面
  def self.create_test_face_macos
    model = Sketchup.active_model
    begin
      model.start_operation('创建测试面', true)
<<<<<<< HEAD

      # 创建一个简单的正方形面作为测试
      entities = model.active_entities
      face = entities.add_face([0, 0, 0], [1.m, 0, 0], [1.m, 1.m, 0], [0, 1.m, 0])

=======
      
      # 创建一个简单的正方形面作为测试
      entities = model.entities
      face = entities.add_face([0,0,0], [1.m,0,0], [1.m,1.m,0], [0,1.m,0])
      
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
      if face
        # 将视图聚焦到这个面
        model.active_view.zoom(face)
        model.commit_operation
        UI.messagebox("已创建测试面！\n现在可以用油漆桶工具点击这个面来应用材质。")
<<<<<<< HEAD
        true
      else
        model.abort_operation
        false
      end
    rescue StandardError => e
      model.abort_operation
      puts "Create test face error: #{e.message}"
      false
    end
  end

  # 为JavaScript准备数据（转换Length为毫米数值）
  # @param types [Array<Hash>] 墙体类型数组
  # @return [Array<Hash>] 转换后的类型数组
  def self.types_for_js(types)
    types.map do |type|
      {
        name: type[:name],
        color: type[:color],
        thickness: type[:thickness].to_mm.round(1),
        height: type[:height].to_mm.round(1),
        tag: type[:tag]
      }
=======
        return true
      else
        model.abort_operation
        return false
      end
    rescue => e
      model.abort_operation
      puts "Create test face error: #{e.message}"
      return false
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    end
  end

  # 创建WebDialog对话框
  def self.create_toolbox_dialog
<<<<<<< HEAD
    # 使用系统默认的对话框行为，不强制置顶
    dialog = UI::WebDialog.new(
      '墙体类型工具箱', # 简化标题
      false,              # 不是模态对话框，允许与主窗口交互
      'ZephyrWallTool',   # 偏好设置键
=======
    # 保持面板显示，不会因为失去焦点而隐藏
    dialog = UI::WebDialog.new(
      self.localize_text(:title),  # 使用本地化标题
      false,              # 不是模态对话框，允许与主窗口交互
      "ZephyrWallTool",   # 偏好设置键
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
      400,                # 宽度
      600,                # 高度
      200,                # X位置
      200,                # Y位置
      true                # 可调整大小
    )
<<<<<<< HEAD

    # 设置对话框最小尺寸
    dialog.min_width = 350
    dialog.min_height = 500

    # 🔧 使用系统默认行为，不强制置顶
    puts '📋 使用系统默认对话框行为'

=======
    
    # 设置对话框行为，保持显示
    dialog.set_on_close {
      # 返回false阻止真正的关闭，这样面板不会消失
      false
    }
    
    # 设置对话框最小尺寸
    dialog.min_width = 350
    dialog.min_height = 500
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    html_content = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
<<<<<<< HEAD
          body {#{' '}
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif;#{' '}
            margin: 0;#{' '}
=======
          body { 
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif; 
            margin: 0; 
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            background: #f5f5f5;
            font-size: 12px;
          }
          .title-bar {
            background: linear-gradient(to bottom, #f8f8f8, #e8e8e8);
            padding: 6px 12px;
            border-bottom: 1px solid #d0d0d0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: move;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
          }
          .title-text {
            font-weight: 600;
            color: #333;
            font-size: 13px;
          }
<<<<<<< HEAD

=======
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
          .window-controls {
            display: flex;
            gap: 6px;
          }
          .control-btn {
            width: 13px;
            height: 13px;
            border-radius: 50%;
            border: 0.5px solid rgba(0,0,0,0.2);
            cursor: pointer;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.3);
          }
          .minimize-btn { background: linear-gradient(to bottom, #ffdb4c, #ffcd02); }
          .maximize-btn { background: linear-gradient(to bottom, #3fc950, #57d038); }
          .content {
            padding: 12px;
            background: white;
            transition: all 0.3s ease;
          }
          .content.minimized {
            display: none;
          }
<<<<<<< HEAD
          .toolbar {#{' '}
            margin-bottom: 12px;#{' '}
=======
          .toolbar { 
            margin-bottom: 12px; 
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            display: flex;
            gap: 8px;
          }
          .toolbar button {
            background: linear-gradient(to bottom, #fafafa, #e8e8e8);
            border: 1px solid #c0c0c0;
            border-radius: 3px;
            padding: 4px 8px;
            font-size: 11px;
            cursor: pointer;
            box-shadow: 0 1px 1px rgba(0,0,0,0.05);
          }
          .toolbar button:hover {
            background: linear-gradient(to bottom, #f0f0f0, #d8d8d8);
          }
          .toolbar button:active {
            background: linear-gradient(to bottom, #d8d8d8, #e8e8e8);
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.1);
          }
<<<<<<< HEAD
          .type-list {#{' '}
            border: 1px solid #d0d0d0;#{' '}
            padding: 8px;#{' '}
            margin-bottom: 12px;#{' '}
            max-height: 300px;#{' '}
=======
          .type-list { 
            border: 1px solid #d0d0d0; 
            padding: 8px; 
            margin-bottom: 12px; 
            max-height: 300px; 
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            overflow-y: auto;
            background: white;
            border-radius: 3px;
          }
<<<<<<< HEAD
          .type-item {#{' '}
            padding: 6px 8px;#{' '}
            margin: 2px 0;#{' '}
=======
          .type-item { 
            padding: 6px 8px; 
            margin: 2px 0; 
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            border: 1px solid #e8e8e8;
            cursor: pointer;
            border-radius: 3px;
            font-size: 11px;
            background: #fafafa;
            transition: all 0.2s ease;
<<<<<<< HEAD
            user-select: none;
          }
          .type-item:hover {#{' '}
            background: linear-gradient(to bottom, #e8f4fd, #d1e7f7);#{' '}
            border-color: #4a90e2;
            box-shadow: 0 2px 4px rgba(74, 144, 226, 0.2);
            transform: translateY(-1px);
          }
          .type-item.selected {#{' '}
            background: linear-gradient(to bottom, #4a90e2, #357abd);#{' '}
            color: white;#{' '}
            border-color: #2968a3;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.2);
          }
          .type-item.active {
            background: linear-gradient(to right, #e3f2fd, #bbdefb) !important;
            border-color: #2196f3 !important;
            border-width: 2px !important;
            box-shadow: 0 2px 8px rgba(33, 150, 243, 0.3) !important;
            transform: translateY(-1px) !important;
          }
=======
          }
          .type-item:hover { 
            background: #f0f8ff; 
            border-color: #b8d4f0;
          }
          .type-item.selected { 
            background: linear-gradient(to bottom, #4a90e2, #357abd); 
            color: white; 
            border-color: #2968a3;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.2);
          }
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
          .native-mode {
            text-align: center;
            padding: 20px;
            background: #f8f8f8;
            border-radius: 3px;
            margin-bottom: 12px;
          }
          .native-btn {
            background: linear-gradient(to bottom, #4a90e2, #357abd);
            color: white;
            border: none;
            border-radius: 3px;
            padding: 8px 16px;
            font-size: 12px;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
          }
          .native-btn:hover {
            background: linear-gradient(to bottom, #5ba0f2, #4080cd);
          }
<<<<<<< HEAD
          .color-preview { \n            width: 30px; \n            height: 20px; \n            border: 1px solid #ccc; \n            display: inline-block; \n            margin-left: 5px; \n            border-radius: 3px;\n          }\n          \n          /* 颜色选择器样式 */\n          .color-palette {\n            border: 1px solid #ddd;\n            border-radius: 4px;\n            padding: 8px;\n            background: #fafafa;\n            margin-bottom: 8px;\n          }\n          \n          .color-row {\n            display: flex;\n            gap: 4px;\n            margin-bottom: 4px;\n          }\n          \n          .color-row:last-child {\n            margin-bottom: 0;\n          }\n          \n          .color-swatch {\n            width: 24px;\n            height: 24px;\n            border: 2px solid #fff;\n            border-radius: 3px;\n            cursor: pointer;\n            transition: all 0.2s ease;\n            box-shadow: 0 1px 3px rgba(0,0,0,0.2);\n            display: flex;\n            align-items: center;\n            justify-content: center;\n          }\n          \n          .color-swatch:hover {\n            transform: scale(1.1);\n            box-shadow: 0 2px 6px rgba(0,0,0,0.3);\n            border-color: #4a90e2;\n          }\n          \n          .color-swatch.selected {\n            border-color: #4a90e2;\n            border-width: 3px;\n            transform: scale(1.05);\n          }\n          \n          .custom-color {\n            background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);\n            color: white;\n            font-weight: bold;\n            text-shadow: 1px 1px 2px rgba(0,0,0,0.5);\n          }
          .draw-btn {
            background: linear-gradient(to bottom, #28a745, #1e7e34);
            color: white;
            border: none;
            border-radius: 3px;
            padding: 4px 8px;
            font-size: 10px;
            cursor: pointer;
            box-shadow: 0 1px 2px rgba(0,0,0,0.2);
            margin-left: 8px;
          }
          .draw-btn:hover {
            background: linear-gradient(to bottom, #34ce57, #28a745);
          }
          .draw-btn:active {
            background: linear-gradient(to bottom, #1e7e34, #28a745);
          }
          .form-group {
            margin-bottom: 12px;
          }
          .form-group label {
            display: block;
            margin-bottom: 4px;
            font-weight: 500;
            font-size: 11px;
            color: #333;
          }
          .form-group input[type="text"],#{' '}
          .form-group input[type="number"] {
            width: 100%;
            padding: 6px 8px;
            border: 1px solid #ccc;
            border-radius: 3px;
            font-size: 11px;
            box-sizing: border-box;
          }
          .color-buttons {
            margin-bottom: 8px;
          }
          .color-buttons button {
            background: linear-gradient(to bottom, #f0f0f0, #e0e0e0);
            border: 1px solid #ccc;
            border-radius: 3px;
            padding: 6px 12px;
            font-size: 11px;
            cursor: pointer;
            margin-right: 8px;
          }
          .color-buttons button:hover {
            background: linear-gradient(to bottom, #e8e8e8, #d8d8d8);
          }
          .color-selection {
            margin-bottom: 8px;
          }
          .color-picker-btn {
            width: 100%;
            padding: 12px 16px;
            background: linear-gradient(to bottom, #4a90e2, #357abd);
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          .color-picker-btn:hover {
            background: linear-gradient(to bottom, #357abd, #2968a3);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
          }
          .color-picker-btn:active {
            transform: translateY(0);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          }
          .color-info {
            margin-top: 6px;
            text-align: center;
          }
          .color-info small {
            color: #666;
            font-size: 10px;
          }
          .color-preview {
            width: 20px;
            height: 20px;
            display: inline-block;
            border: 2px solid #999;
            vertical-align: middle;
            margin-left: 8px;
            border-radius: 4px;
=======
          .color-preview {
            width: 16px;
            height: 16px;
            display: inline-block;
            border: 1px solid #999;
            vertical-align: middle;
            margin-left: 6px;
            border-radius: 2px;
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            box-shadow: inset 0 1px 1px rgba(0,0,0,0.1);
          }
        </style>
      </head>
      <body>
        <div class="title-bar">
<<<<<<< HEAD
          <div style="display: flex; align-items: center;">
            <div class="title-text">墙体类型工具箱</div>
          </div>
          <div class="window-controls">
            <button class="control-btn minimize-btn" onclick="toggleMinimize()" title="最小化"></button>
          </div>
        </div>
        <div class="content" id="mainContent">

      #{'    '}
          <div class="toolbar">
            <button onclick="showAddForm()">网页版添加</button>
            <button onclick="deleteSelected()">删除选中</button>
            <button onclick="showStatistics()">统计报告</button>
          </div>
          <div class="toolbar" style="border-top: 1px solid #ddd; padding-top: 8px; margin-top: 8px;">
            <button onclick="createWallTags()" style="background: linear-gradient(to bottom, #ff8c00, #ff7518); color: white;">创建墙体Tags</button>
            <button onclick="generateFromTags()" style="background: linear-gradient(to bottom, #8a2be2, #6a1b9a); color: white;">从Tags生成墙体</button>
          </div>
          <div style="background: #f0f8ff; padding: 8px; border-radius: 3px; margin-bottom: 12px; font-size: 10px; color: #666;">
            <strong>新工作流程：</strong><br>
            1. 点击"创建墙体Tags"为每种墙体类型创建标签<br>
            2. 使用原生Line/Arc工具绘制墙体中线<br>
            3. 将线段分配到对应的墙体Tag<br>
            4. 点击"从Tags生成墙体"一次性生成所有墙体
=======
          <div class="title-text">墙体类型工具箱</div>
          <div class="window-controls">
            <button class="control-btn minimize-btn" onclick="toggleMinimize()" title="最小化"></button>
            <button class="control-btn maximize-btn" onclick="toggleMaximize()" title="置顶"></button>
          </div>
        </div>
        <div class="content" id="mainContent">
          <div class="native-mode">
            <button class="native-btn" onclick="useNativeDialog()">使用原生对话框添加</button>
            <div style="margin-top: 8px; font-size: 10px; color: #666;">
              使用SketchUp原生界面风格
            </div>
          </div>
          
          <div class="toolbar">
            <button onclick="showAddForm()">网页版添加</button>
            <button onclick="deleteSelected()">删除选中</button>
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
          </div>
          <div id="typeList" class="type-list"></div>
          <div id="addForm" style="display: none;">
            <div class="form-group">
              <label>类型名称:</label>
              <input type="text" id="typeName">
            </div>
            <div class="form-group">
              <label>颜色选择:</label>
<<<<<<< HEAD
              <div class="color-selection">
                <!-- 内置颜色选择器 -->
                <div class="color-palette">
                  <!-- 第一行：基础颜色 -->
                  <div class="color-row">
                    <div class="color-swatch" style="background-color: #FF6B6B;" onclick="selectColor('#FF6B6B')" title="红色"></div>
                    <div class="color-swatch" style="background-color: #FFE66D;" onclick="selectColor('#FFE66D')" title="黄色"></div>
                    <div class="color-swatch" style="background-color: #4ECDC4;" onclick="selectColor('#4ECDC4')" title="青色"></div>
                    <div class="color-swatch" style="background-color: #45B7D1;" onclick="selectColor('#45B7D1')" title="蓝色"></div>
                    <div class="color-swatch" style="background-color: #96CEB4;" onclick="selectColor('#96CEB4')" title="绿色"></div>
                    <div class="color-swatch" style="background-color: #FFEAA7;" onclick="selectColor('#FFEAA7')" title="浅黄"></div>
                    <div class="color-swatch" style="background-color: #DDA0DD;" onclick="selectColor('#DDA0DD')" title="紫色"></div>
                    <div class="color-swatch" style="background-color: #98D8C8;" onclick="selectColor('#98D8C8')" title="薄荷绿"></div>
                  </div>
                  <!-- 第二行：深色调 -->
                  <div class="color-row">
                    <div class="color-swatch" style="background-color: #FF3838;" onclick="selectColor('#FF3838')" title="深红"></div>
                    <div class="color-swatch" style="background-color: #FFDD59;" onclick="selectColor('#FFDD59')" title="金黄"></div>
                    <div class="color-swatch" style="background-color: #26D0CE;" onclick="selectColor('#26D0CE')" title="深青"></div>
                    <div class="color-swatch" style="background-color: #3742FA;" onclick="selectColor('#3742FA')" title="深蓝"></div>
                    <div class="color-swatch" style="background-color: #2ED573;" onclick="selectColor('#2ED573')" title="深绿"></div>
                    <div class="color-swatch" style="background-color: #FFA502;" onclick="selectColor('#FFA502')" title="橙色"></div>
                    <div class="color-swatch" style="background-color: #5F27CD;" onclick="selectColor('#5F27CD')" title="深紫"></div>
                    <div class="color-swatch" style="background-color: #00D2D3;" onclick="selectColor('#00D2D3')" title="青绿"></div>
                  </div>
                  <!-- 第三行：建筑常用色 -->
                  <div class="color-row">
                    <div class="color-swatch" style="background-color: #8B4513;" onclick="selectColor('#8B4513')" title="棕色"></div>
                    <div class="color-swatch" style="background-color: #D2691E;" onclick="selectColor('#D2691E')" title="巧克力色"></div>
                    <div class="color-swatch" style="background-color: #CD853F;" onclick="selectColor('#CD853F')" title="秘鲁色"></div>
                    <div class="color-swatch" style="background-color: #F4A460;" onclick="selectColor('#F4A460')" title="沙棕色"></div>
                    <div class="color-swatch" style="background-color: #2F4F4F;" onclick="selectColor('#2F4F4F')" title="深灰绿"></div>
                    <div class="color-swatch" style="background-color: #708090;" onclick="selectColor('#708090')" title="石板灰"></div>
                    <div class="color-swatch" style="background-color: #778899;" onclick="selectColor('#778899')" title="浅石板灰"></div>
                    <div class="color-swatch" style="background-color: #B0C4DE;" onclick="selectColor('#B0C4DE')" title="浅钢蓝"></div>
                  </div>
                  <!-- 第四行：灰度色 -->
                  <div class="color-row">
                    <div class="color-swatch" style="background-color: #000000;" onclick="selectColor('#000000')" title="黑色"></div>
                    <div class="color-swatch" style="background-color: #404040;" onclick="selectColor('#404040')" title="深灰"></div>
                    <div class="color-swatch" style="background-color: #808080;" onclick="selectColor('#808080')" title="灰色"></div>
                    <div class="color-swatch" style="background-color: #C0C0C0;" onclick="selectColor('#C0C0C0')" title="银色"></div>
                    <div class="color-swatch" style="background-color: #E0E0E0;" onclick="selectColor('#E0E0E0')" title="浅灰"></div>
                    <div class="color-swatch" style="background-color: #F5F5F5;" onclick="selectColor('#F5F5F5')" title="烟白"></div>
                    <div class="color-swatch" style="background-color: #FFFFFF;" onclick="selectColor('#FFFFFF')" title="白色"></div>
                    <div class="color-swatch custom-color" onclick="openSystemColorPicker()" title="自定义颜色">
                      <span style="font-size: 12px;">🎨</span>
                    </div>
                  </div>
                </div>
                <div class="color-info" style="margin-top: 8px;">
                  <small>点击颜色块选择，或点击🎨使用系统颜色选择器</small>
                </div>
              </div>
              <input type="hidden" id="typeColor" value="#808080">
              <div id="colorPreview" class="color-preview" style="background-color: #808080; margin-top: 8px;"></div>
=======
              <div class="color-buttons">
                <button onclick="openMaterialsPanel()">材质面板</button>
                <button onclick="getMaterialColor()">获取材质</button>
                <button onclick="inputCustomColor()">自定义</button>
              </div>
              <div class="color-buttons">
                <button onclick="createTestFace()" style="background: #f0f8ff;">创建测试面</button>
                <small style="color: #666;">用于测试材质的临时面</small>
              </div>
              <div class="color-presets">
                <div class="color-preset" style="background-color: #FF0000;" onclick="setPresetColor('#FF0000')" title="红色"></div>
                <div class="color-preset" style="background-color: #0000FF;" onclick="setPresetColor('#0000FF')" title="蓝色"></div>
                <div class="color-preset" style="background-color: #00FF00;" onclick="setPresetColor('#00FF00')" title="绿色"></div>
                <div class="color-preset" style="background-color: #FFFF00;" onclick="setPresetColor('#FFFF00')" title="黄色"></div>
                <div class="color-preset" style="background-color: #FF8000;" onclick="setPresetColor('#FF8000')" title="橙色"></div>
                <div class="color-preset" style="background-color: #8000FF;" onclick="setPresetColor('#8000FF')" title="紫色"></div>
                <div class="color-preset" style="background-color: #804000;" onclick="setPresetColor('#804000')" title="棕色"></div>
                <div class="color-preset" style="background-color: #808080;" onclick="setPresetColor('#808080')" title="灰色"></div>
              </div>
              <div id="colorPreview" class="color-preview" style="background-color: #808080;"></div>
              <input type="hidden" id="typeColor" value="#808080">
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            </div>
            <div class="form-group">
              <label>厚度 (mm):</label>
              <input type="number" id="typeThickness" value="200">
            </div>
            <div class="form-group">
              <label>高度 (mm):</label>
              <input type="number" id="typeHeight" value="2800">
            </div>
            <div class="form-group">
              <label>标签:</label>
              <input type="text" id="typeTag">
            </div>
            <button onclick="addType()">保存</button>
            <button onclick="hideAddForm()">取消</button>
          </div>
          <script>
            let selectedTypeIndex = -1;
<<<<<<< HEAD
            let currentActiveTypeIndex = -1; // 新增：跟踪当前激活的墙体类型
      #{'      '}
            function updateTypeList(types) {
              console.log('updateTypeList called with:', types);
              console.log('Types count:', types.length);
      #{'        '}
=======
            
            function updateTypeList(types) {
              console.log('updateTypeList called with:', types);
              console.log('Types count:', types.length);
              
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
              const list = document.getElementById('typeList');
              if (!list) {
                console.error('typeList element not found!');
                return;
              }
<<<<<<< HEAD
      #{'        '}
=======
              
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
              list.innerHTML = '';
              types.forEach((type, index) => {
                console.log('Adding type:', type);
                const div = document.createElement('div');
                div.className = 'type-item';
<<<<<<< HEAD
                div.id = `type-item-${index}`; // 添加ID用于状态管理
      #{'          '}
                // 左键点击切换墙体类型状态
                div.onclick = () => toggleWallType(index);
      #{'          '}
                // 右键显示上下文菜单
                div.oncontextmenu = (event) => {
                  event.preventDefault();
                  showContextMenu(event, index);
                  return false;
                };
      #{'          '}
                div.innerHTML = `
                  <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                    <div style="flex: 1;">
                      <strong>${type.name}</strong>
                      <div class="color-preview" style="background-color: ${type.color};"></div><br>
                      厚度: ${Math.round(type.thickness)}mm | 高度: ${Math.round(type.height)}mm<br>
                      标签: ${type.tag}
                    </div>
                    <div class="tag-indicator" style="background: linear-gradient(to bottom, #17a2b8, #138496); color: white; padding: 4px 8px; border-radius: 3px; font-size: 10px;">
                      🏷️ Tag
                    </div>
                  </div>
                `;
                list.appendChild(div);
              });
      #{'        '}
              // 恢复之前的激活状态
              if (currentActiveTypeIndex >= 0 && currentActiveTypeIndex < types.length) {
                updateTypeItemAppearance(currentActiveTypeIndex, true);
              }
      #{'        '}
              console.log('typeList updated, children count:', list.children.length);
            }
      #{'      '}
            // 新增：切换墙体类型状态
            function toggleWallType(index) {
              console.log('toggleWallType called with index:', index);
      #{'        '}
              if (currentActiveTypeIndex === index) {
                // 再次点击同一按钮 - 取消激活，回到默认图层
                console.log('取消激活墙体类型:', index);
                currentActiveTypeIndex = -1;
                updateTypeItemAppearance(index, false);
                switchToDefaultLayer();
              } else {
                // 点击不同按钮 - 切换到新的墙体类型
                console.log('切换到墙体类型:', index);
      #{'          '}
                // 取消之前激活的按钮
                if (currentActiveTypeIndex >= 0) {
                  updateTypeItemAppearance(currentActiveTypeIndex, false);
                }
      #{'          '}
                // 激活新按钮
                currentActiveTypeIndex = index;
                updateTypeItemAppearance(index, true);
                switchToTag(index);
              }
            }
      #{'      '}
            // 新增：更新墙体类型项的外观
            function updateTypeItemAppearance(index, isActive) {
              const item = document.getElementById(`type-item-${index}`);
              if (!item) return;
      #{'        '}
              if (isActive) {
                item.classList.add('active');
              } else {
                item.classList.remove('active');
              }
            }
      #{'      '}
            // 新增：切换到默认图层
            function switchToDefaultLayer() {
              console.log('切换到默认图层');
              window.location.href = 'skp:switchToDefaultLayer@';
            }
      #{'      '}
=======
                div.onclick = () => selectType(index);
                div.innerHTML = `
                  <strong>${type.name}</strong>
                  <div class="color-preview" style="background-color: ${type.color};"></div><br>
                  厚度: ${Math.round(type.thickness)}mm | 高度: ${Math.round(type.height)}mm<br>
                  标签: ${type.tag}
                `;
                list.appendChild(div);
              });
              console.log('typeList updated, children count:', list.children.length);
            }
            
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            function selectType(index) {
              selectedTypeIndex = index;
              document.querySelectorAll('.type-item').forEach((item, i) => {
                item.className = i === index ? 'type-item selected' : 'type-item';
              });
            }
<<<<<<< HEAD
      #{'      '}
            // 显示右键上下文菜单
            function showContextMenu(event, typeIndex) {
              // 移除已存在的菜单
              const existingMenu = document.getElementById('contextMenu');
              if (existingMenu) {
                existingMenu.remove();
              }
      #{'        '}
              // 创建上下文菜单
              const menu = document.createElement('div');
              menu.id = 'contextMenu';
              menu.style.cssText = `
                position: fixed;
                left: ${event.clientX}px;
                top: ${event.clientY}px;
                background: white;
                border: 1px solid #ccc;
                border-radius: 4px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.2);
                z-index: 1000;
                min-width: 120px;
                font-size: 12px;
              `;
      #{'        '}
              menu.innerHTML = `
                <div class="menu-item" onclick="copyType(${typeIndex})" style="padding: 8px 12px; cursor: pointer; border-bottom: 1px solid #eee;">
                  📋 复制
                </div>
                <div class="menu-item" onclick="editType(${typeIndex})" style="padding: 8px 12px; cursor: pointer; border-bottom: 1px solid #eee;">
                  ✏️ 编辑
                </div>
                <div class="menu-item" onclick="deleteType(${typeIndex})" style="padding: 8px 12px; cursor: pointer; color: #dc3545;">
                  🗑️ 删除
                </div>
              `;
      #{'        '}
              // 添加菜单项悬停效果
              const style = document.createElement('style');
              style.textContent = `
                .menu-item:hover {
                  background-color: #f8f9fa;
                }
              `;
              document.head.appendChild(style);
      #{'        '}
              document.body.appendChild(menu);
      #{'        '}
              // 点击其他地方关闭菜单
              setTimeout(() => {
                document.addEventListener('click', function closeMenu() {
                  menu.remove();
                  document.removeEventListener('click', closeMenu);
                });
              }, 100);
            }
      #{'      '}
            // 复制墙体类型
            function copyType(typeIndex) {
              window.location.href = 'skp:copyType@' + typeIndex;
            }
      #{'      '}
            // 编辑墙体类型
            function editType(typeIndex) {
              window.location.href = 'skp:editType@' + typeIndex;
            }
      #{'      '}
            // 删除墙体类型
            function deleteType(typeIndex) {
              if (confirm('确定要删除这个墙体类型吗？')) {
                window.location.href = 'skp:deleteType@' + typeIndex;
              }
            }
      #{'      '}
=======
            
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            function showAddForm() {
              document.getElementById('addForm').style.display = 'block';
              document.getElementById('typeName').value = '';
              document.getElementById('typeColor').value = '#808080';
              document.getElementById('colorPreview').style.backgroundColor = '#808080';
              document.getElementById('typeThickness').value = '200';
              document.getElementById('typeHeight').value = '2800';
              document.getElementById('typeTag').value = '';
            }
<<<<<<< HEAD
      #{'      '}
            function hideAddForm() {
              document.getElementById('addForm').style.display = 'none';
            }
      #{'      '}

      #{'      '}
            function openSystemColorPicker() {
              window.location.href = 'skp:openSystemColorPicker@';
            }
      #{'      '}
            function inputCustomColor() {
              window.location.href = 'skp:inputCustomColor@';
            }
      #{'      '}
            function setPresetColor(color) {
              setColor(color);
            }
      #{'      '}
            function selectColor(color) {
              // 移除之前选中的颜色块
              document.querySelectorAll('.color-swatch').forEach(swatch => {
                swatch.classList.remove('selected');
              });
      #{'        '}
              // 标记当前选中的颜色块
              event.target.classList.add('selected');
      #{'        '}
              // 设置颜色
              setColor(color);
            }
      #{'      '}
=======
            
            function hideAddForm() {
              document.getElementById('addForm').style.display = 'none';
            }
            
            function openMaterialsPanel() {
              window.location.href = 'skp:openMaterialsPanel@';
            }
            
            function getMaterialColor() {
              window.location.href = 'skp:getMaterialColor@';
            }
            
            function inputCustomColor() {
              window.location.href = 'skp:inputCustomColor@';
            }
            
            function setPresetColor(color) {
              setColor(color);
            }
            
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            function setColor(color) {
              document.getElementById('typeColor').value = color;
              document.getElementById('colorPreview').style.backgroundColor = color;
            }
<<<<<<< HEAD
      #{'      '}
            function addType() {
              console.log('addType function called');
      #{'        '}
=======
            
            function addType() {
              console.log('addType function called');
              
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
              const name = document.getElementById('typeName').value;
              const color = document.getElementById('typeColor').value;
              const thickness = document.getElementById('typeThickness').value;
              const height = document.getElementById('typeHeight').value;
              const tag = document.getElementById('typeTag').value;
<<<<<<< HEAD
      #{'        '}
              console.log('Form values:', { name, color, thickness, height, tag });
      #{'        '}
=======
              
              console.log('Form values:', { name, color, thickness, height, tag });
              
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
              if (!name.trim()) {
                alert('请输入类型名称');
                return;
              }
<<<<<<< HEAD
      #{'        '}
              const url = 'skp:addType@' + encodeURIComponent(name) + ',' + encodeURIComponent(color) + ',' + encodeURIComponent(thickness) + ',' + encodeURIComponent(height) + ',' + encodeURIComponent(tag);
              console.log('Calling Ruby with URL:', url);
      #{'        '}
=======
              
              const url = 'skp:addType@' + encodeURIComponent(name) + ',' + encodeURIComponent(color) + ',' + encodeURIComponent(thickness) + ',' + encodeURIComponent(height) + ',' + encodeURIComponent(tag);
              console.log('Calling Ruby with URL:', url);
              
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
              window.location.href = url;
              hideAddForm();
              console.log('addType completed');
            }
<<<<<<< HEAD
      #{'      '}
=======
            
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            function deleteSelected() {
              if (selectedTypeIndex === -1) {
                alert('请先选择一个类型');
                return;
              }
              if (confirm('确定要删除选中的类型吗？')) {
                window.location.href = 'skp:deleteType@' + selectedTypeIndex;
              }
            }
<<<<<<< HEAD
      #{'      '}
            function createTestFace() {
              window.location.href = 'skp:createTestFace@';
            }
      #{'      '}
            function useNativeDialog() {
              window.location.href = 'skp:useNativeDialog@';
            }
      #{'      '}
            function switchToTag(typeIndex) {
              console.log('Switching to tag for type index:', typeIndex);
              window.location.href = 'skp:switchToTag@' + typeIndex;
            }
      #{'      '}
=======
            
            function createTestFace() {
              window.location.href = 'skp:createTestFace@';
            }
            
            function useNativeDialog() {
              window.location.href = 'skp:useNativeDialog@';
            }
            
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            let isMinimized = false;
            function toggleMinimize() {
              const content = document.getElementById('mainContent');
              isMinimized = !isMinimized;
              if (isMinimized) {
                content.style.display = 'none';
<<<<<<< HEAD
              } else {
                content.style.display = 'block';
              }
            }
      #{'      '}
            // 初始化
            window.onload = function() {
              window.updateTypeList = updateTypeList;
              updateTypeList(#{types_for_js(all_types).to_json});
      #{'        '}
              console.log('✅ 墙体类型工具箱已启动');
            }
      #{'      '}
            function showStatistics() {
              window.location.href = 'skp:showStatistics@';
            }
      #{'      '}
            function createWallTags() {
              window.location.href = 'skp:createWallTags@';
            }
      #{'      '}
            function generateFromTags() {
              window.location.href = 'skp:generateFromTags@';
            }
      #{'      '}
            // 颜色选择器状态管理函数
            function showColorPickerLoading() {
              const button = document.querySelector('button[onclick*="openSystemColorPicker"]');
              if (button) {
                button.disabled = true;
                button.textContent = '🔄 选择中...';
              }
            }
      #{'      '}
            function hideColorPickerLoading() {
              const button = document.querySelector('button[onclick*="openSystemColorPicker"]');
              if (button) {
                button.disabled = false;
                button.textContent = '🎨';
              }
            }
      #{'      '}
            function showColorPickerCancelled() {
              console.log('用户取消了颜色选择');
              // 可以在这里添加用户提示
            }
      #{'      '}
            function showColorPickerError(message) {
              console.error('颜色选择器错误:', message);
              alert('颜色选择器出错: ' + message);
=======
                window.location.href = 'skp:setMinimized@true';
              } else {
                content.style.display = 'block';
                window.location.href = 'skp:setMinimized@false';
              }
            }
            
            function toggleMaximize() {
              window.location.href = 'skp:toggleStayOnTop@';
            }
            
            // 初始化
            window.onload = function() {
              window.updateTypeList = updateTypeList;
              updateTypeList(#{self.types_for_js(self.all_types).to_json});
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
            }
          </script>
        </div>
      </body>
      </html>
    HTML
    dialog.set_html(html_content)
<<<<<<< HEAD

    # 🆕 增强的事件回调处理
    dialog.add_action_callback('addType') do |_action_context, params|
      puts "addType callback triggered with params: #{params}"

      begin
        name, color, thickness, height, tag = params.split(',').map { |v| CGI.unescape(v) }
        puts "Parsed values: name=#{name}, color=#{color}, thickness=#{thickness}, height=#{height}, tag=#{tag}"

        types = all_types
        puts "Current types count: #{types.length}"

=======
    
    dialog.add_action_callback("addType") { |action_context, params|
      puts "addType callback triggered with params: #{params}"
      
      begin
        name, color, thickness, height, tag = params.split(',').map { |v| CGI.unescape(v) }
        puts "Parsed values: name=#{name}, color=#{color}, thickness=#{thickness}, height=#{height}, tag=#{tag}"
        
        types = self.all_types
        puts "Current types count: #{types.length}"
        
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
        new_type = {
          name: name,
          color: color,
          thickness: thickness.to_f.mm,
          height: height.to_f.mm,
          tag: tag
        }
        puts "New type created: #{new_type}"
<<<<<<< HEAD

        types << new_type
        puts "Types count after adding: #{types.length}"
        puts "New type being added: #{new_type.inspect}"

        save_types(types)

        # 确保更新列表
        updated_types = all_types
        puts "Updated types count: #{updated_types.length}"

        types_json = types_for_js(updated_types).to_json
        puts "Sending to JS: #{types_json}"

        dialog.execute_script("updateTypeList(#{types_json})")
        puts 'execute_script called successfully'
      rescue StandardError => e
=======
        
        types << new_type
        puts "Types count after adding: #{types.length}"
        puts "New type being added: #{new_type.inspect}"
        
        self.save_types(types)
        
        # 确保更新列表
        updated_types = self.all_types
        puts "Updated types count: #{updated_types.length}"
        
        types_json = self.types_for_js(updated_types).to_json
        puts "Sending to JS: #{types_json}"
        
        dialog.execute_script("updateTypeList(#{types_json})")
        puts "execute_script called successfully"
        
      rescue => e
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
        puts "Error in addType: #{e.message}"
        puts e.backtrace
        UI.messagebox("保存失败: #{e.message}")
      end
<<<<<<< HEAD
    end

    dialog.add_action_callback('deleteType') do |_action_context, index|
      types = all_types
      types.delete_at(index.to_i)
      save_types(types)
      dialog.execute_script("updateTypeList(#{types_for_js(types).to_json})")
    end

    dialog.add_action_callback('copyType') do |_action_context, index|
      types = all_types
      original_type = types[index.to_i]

      if original_type
        # 创建副本，名称添加"副本"后缀
        copied_type = original_type.dup
        copied_type[:name] = "#{original_type[:name]} 副本"

        types << copied_type
        save_types(types)

        # 更新界面
        dialog.execute_script("updateTypeList(#{types_for_js(types).to_json})")
        puts "已复制墙体类型: #{copied_type[:name]}"
      end
    rescue StandardError => e
      puts "复制墙体类型时出错: #{e.message}"
      UI.messagebox("复制失败: #{e.message}")
    end

    dialog.add_action_callback('editType') do |_action_context, index|
      types = all_types
      type_to_edit = types[index.to_i]

      if type_to_edit
        # 创建编辑对话框
        create_edit_type_dialog(type_to_edit, index.to_i, dialog)
      end
    rescue StandardError => e
      puts "编辑墙体类型时出错: #{e.message}"
      UI.messagebox("编辑失败: #{e.message}")
    end

    dialog.add_action_callback('openSystemColorPicker') do |_action_context|
      puts '🎨 用户点击了系统颜色选择器按钮'

      begin
        # 显示加载提示
        dialog.execute_script('showColorPickerLoading()')

        # 优先使用安全的颜色选择器
        color = open_safe_color_picker

        # 如果安全选择器失败，尝试系统选择器
        if color.nil?
          puts '🔄 尝试系统颜色选择器...'
          color = open_system_color_picker_macos
        end

        # 隐藏加载提示
        dialog.execute_script('hideColorPickerLoading()')

        if color
          # 转换颜色为十六进制格式
          hex_color = if color.is_a?(Sketchup::Color)
                        format('#%02X%02X%02X', color.red, color.green, color.blue)
                      else
                        color.to_s
                      end
          puts "✅ 颜色选择成功，设置为: #{hex_color}"
          dialog.execute_script("setColor('#{hex_color}')")
        else
          puts '❌ 用户取消了颜色选择'
          # 可以选择显示一个提示消息
          dialog.execute_script('showColorPickerCancelled()')
        end
      rescue StandardError => e
        puts "❌ 系统颜色选择器回调错误: #{e.message}"
        dialog.execute_script('hideColorPickerLoading()')
        dialog.execute_script("showColorPickerError('#{e.message.gsub("'", "\\'")}')")
      end
    end

    dialog.add_action_callback('inputCustomColor') do |_action_context|
      result = UI.inputbox(
        ['颜色名称或十六进制值 (如: Red, #FF0000):'],
        ['#FF0000'],
        '输入自定义颜色'
=======
    }
    
    dialog.add_action_callback("deleteType") { |action_context, index|
      types = self.all_types
      types.delete_at(index.to_i)
      self.save_types(types)
      dialog.execute_script("updateTypeList(#{self.types_for_js(types).to_json})")
    }
    
    dialog.add_action_callback("openMaterialsPanel") { |action_context|
      self.open_materials_panel_macos
    }
    
    dialog.add_action_callback("getMaterialColor") { |action_context|
      color, debug_info = self.get_current_material_color_macos
      if color
        # 转换颜色为十六进制格式
        if color.is_a?(Sketchup::Color)
          hex_color = sprintf("#%02X%02X%02X", color.red, color.green, color.blue)
        else
          hex_color = color.to_s
        end
        dialog.execute_script("setColor('#{hex_color}')")
      else
        UI.messagebox("无法获取材质颜色\n\n调试信息:\n#{debug_info.join("\n")}\n\n请使用预设颜色或自定义颜色")
      end
    }
    
    dialog.add_action_callback("inputCustomColor") { |action_context|
      result = UI.inputbox(
        ["颜色名称或十六进制值 (如: Red, #FF0000):"], 
        ["#FF0000"], 
        "输入自定义颜色"
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
      )
      if result && !result[0].empty?
        color_input = result[0].strip
        dialog.execute_script("setColor('#{color_input}')")
      end
<<<<<<< HEAD
    end

    dialog.add_action_callback('showStatistics') do |_action_context|
      show_wall_statistics
    end

    dialog.add_action_callback('createWallTags') do |_action_context|
      create_all_wall_tags
    end

    dialog.add_action_callback('generateFromTags') do |_action_context|
      generate_walls_from_tags
    end

    dialog.add_action_callback('switchToTag') do |_action_context, type_index|
      index = type_index.to_i
      types = all_types

      if index >= 0 && index < types.length
        wall_type = types[index]
        switch_to_wall_tag(wall_type)
      else
        UI.messagebox("无效的墙体类型索引: #{index}")
      end
    rescue StandardError => e
      puts "切换Tag时出错: #{e.message}"
      puts e.backtrace
      UI.messagebox("切换Tag时出错: #{e.message}")
    end

    dialog.add_action_callback('switchToDefaultLayer') do |_action_context|
      switch_to_default_layer
    rescue StandardError => e
      puts "切换到默认图层时出错: #{e.message}"
      puts e.backtrace
    end

    # 显示对话框
    dialog.show

=======
    }
    
    dialog.add_action_callback("useNativeDialog") { |action_context|
      # 使用原生对话框添加类型
      self.native_add_type_dialog
    }
    
    dialog.add_action_callback("createTestFace") { |action_context|
      if self.create_test_face_macos
        # 测试面创建成功，不需要额外提示，create_test_face_macos方法中已有提示
      else
        UI.messagebox("无法创建测试面。请确认模型处于可编辑状态。")
      end
    }
    
    dialog.add_action_callback("setMinimized") { |action_context, minimized|
      # 在macOS上，我们可以调整窗口大小来模拟最小化
      if minimized == "true"
        dialog.set_size(400, 40)  # 只显示标题栏
      else
        dialog.set_size(400, 600) # 恢复正常大小
      end
    }
    
    dialog.add_action_callback("toggleStayOnTop") { |action_context|
      # 尝试让窗口保持在最前面（这在不同SketchUp版本中可能有不同效果）
      begin
        dialog.bring_to_front
        UI.messagebox("已尝试将面板置顶", MB_OK)
      rescue => e
        puts "Stay on top error: #{e.message}"
      end
    }
    
    dialog.show
    
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
    # 存储对话框引用，方便后续操作
    @@current_dialog = dialog
  end

  # 类型管理主入口
  def self.manage_types
<<<<<<< HEAD
    # 先尝试清理可能存在的无效对话框引用
    if defined?(@@current_dialog) && @@current_dialog
      begin
        # 检查对话框是否仍然有效
        @@current_dialog.bring_to_front
        @@current_dialog.show
        puts '✅ 现有对话框已激活'
        return
      rescue StandardError => e
        puts "⚠️ 现有对话框无效，清理并创建新的: #{e.message}"
        # 清理无效的对话框引用
        begin
          @@current_dialog.close
        rescue StandardError
          # 忽略关闭错误
        end
        @@current_dialog = nil
      end
    end

    puts '🔄 创建新的管理对话框...'
    # 创建新的对话框
    create_toolbox_dialog
  end

  # 关闭所有对话框（用于重载时清理）
  def self.close_all_dialogs
    puts '🔄 关闭所有对话框...'
    closed_count = 0

    # 关闭主对话框
    if defined?(@@current_dialog) && @@current_dialog
      begin
        @@current_dialog.close
        puts '  - 已关闭主对话框'
        closed_count += 1
      rescue StandardError => e
        puts "  - 关闭主对话框时出错: #{e.message}"
      ensure
        @@current_dialog = nil
      end
    else
      puts '  - 主对话框不存在或已清理'
    end

    # 关闭编辑对话框
    if defined?(@@edit_dialog) && @@edit_dialog
      begin
        @@edit_dialog.close
        puts '  - 已关闭编辑对话框'
        closed_count += 1
      rescue StandardError => e
        puts "  - 关闭编辑对话框时出错: #{e.message}"
      ensure
        @@edit_dialog = nil
      end
    else
      puts '  - 编辑对话框不存在或已清理'
    end

    # 强制垃圾回收，清理可能的引用
    GC.start

    puts "✅ 对话框清理完成 (关闭了 #{closed_count} 个对话框)"
    closed_count
  rescue StandardError => e
    puts "❌ 关闭对话框时出错: #{e.message}"
    0
  end

  # 为JavaScript准备数据（转换Length为毫米数值）
  # 线程安全的图层切换方法
  def self.safe_layer_switch(model, target_layer)
    puts '🔒 执行线程安全的图层切换...'
    puts "  设置前活动图层: #{model.active_layer ? model.active_layer.name : 'nil'}"
    puts "  目标图层可见性: #{target_layer.visible?}"

    # 🔧 确保目标图层可见（SketchUp不允许设置不可见图层为活动图层）
    unless target_layer.visible?
      puts '  ⚠️ 目标图层不可见，先设为可见'
      target_layer.visible = true
    end

    begin
      # 方法1: 直接设置
      model.active_layer = target_layer
      puts '📝 执行 model.active_layer = target_layer'

      # 立即检查结果
      current_layer_after_set = model.active_layer
      puts "  设置后立即检查: #{current_layer_after_set ? current_layer_after_set.name : 'nil'}"
      puts "  设置是否成功: #{current_layer_after_set == target_layer}"

      if current_layer_after_set != target_layer
        puts '⚠️ 第一次设置失败，使用强化方法...'

        # 方法2: 使用start_operation确保在主线程
        model.start_operation('切换图层', true)
        begin
          # 确保目标图层可见
          target_layer.visible = true

          # 先切换到Layer0再切换到目标图层
          layer0 = model.layers['Layer0'] || model.layers[0]
          if layer0
            puts "  先切换到Layer0: #{layer0.name}"
            model.active_layer = layer0
            puts "  切换到Layer0后: #{model.active_layer ? model.active_layer.name : 'nil'}"
          end

          # 再切换到目标图层
          puts '  再次切换到目标图层...'
          model.active_layer = target_layer

          model.commit_operation

          current_layer_after_retry = model.active_layer
          puts "  重试后结果: #{current_layer_after_retry ? current_layer_after_retry.name : 'nil'}"
          puts "  重试设置是否成功: #{current_layer_after_retry == target_layer}"
        rescue StandardError => e
          model.abort_operation
          puts "  操作中切换失败: #{e.message}"
        end
      end

      # 方法3: 强制UI刷新
      puts '🔄 强制UI刷新...'
      force_ui_refresh_safe

      # 最终验证
      final_active_layer = model.active_layer
      puts '🏁 最终验证结果：'
      puts "  最终活动图层: #{final_active_layer ? final_active_layer.name : 'nil'}"
      puts "  是否为目标Tag: #{final_active_layer == target_layer}"
      puts "  Tag对象ID: #{target_layer.object_id}"
      puts "  最终图层对象ID: #{final_active_layer ? final_active_layer.object_id : 'nil'}"

      final_active_layer == target_layer
    rescue StandardError => e
      puts "❌ 设置活动图层时出错: #{e.message}"
      puts "  错误堆栈: #{e.backtrace.first(3).join("\n  ")}"
      false
    end
  end

  # 线程安全的UI刷新
  def self.force_ui_refresh_safe
    UIRefreshManager.request_refresh(force: false, delay: 0.05)
  end

  # 初始化模块功能
  def self.initialize_module
    # 设置墙体右键菜单
    setup_wall_context_menu
    puts 'Zephyr Wall Tool 模块已初始化'
  end

  # 设置墙体右键菜单（简单实现）
  def self.setup_wall_context_menu
    # 暂时为空实现，避免错误
    puts '墙体右键菜单设置完成'
  end

  # 模块加载时自动初始化
  initialize_module

  # 从边创建墙体段（重构后的主方法）
  # @param entities [Sketchup::Entities] 实体集合
  # @param edge [Sketchup::Edge] 边对象
  # @param wall_type [Hash] 墙体类型配置
  # @param offset_distance [Length] 偏移距离
  # @return [void]
  def self.create_wall_segment_from_edge(entities, edge, wall_type, offset_distance)
    # 参数验证
    validate_wall_segment_parameters(entities, edge, wall_type, offset_distance)

    # 计算墙体几何点
    wall_points = calculate_wall_geometry_points(edge, wall_type, offset_distance)

    # 创建一个组来包含墙体
    wall_group = entities.add_group

    # 在组内创建墙体面
    create_wall_faces(wall_group.entities, wall_points)

    # 应用材质和属性
    apply_wall_material(wall_group, wall_type)

    # 计算墙体属性
    center_length = edge.length
    wall_side_area = center_length * wall_type[:height]
    wall_volume = wall_side_area * wall_type[:thickness]

    # 保存墙体属性
    save_wall_attributes(wall_group, wall_type, center_length, wall_side_area, wall_volume)

    puts "🏗️ 墙体段创建完成: #{edge.start.position} -> #{edge.end.position}"

    # 返回创建的墙体组
    wall_group
  end

  # 验证墙体段创建参数
  # @param entities [Sketchup::Entities] 实体集合
  # @param edge [Sketchup::Edge] 边对象
  # @param wall_type [Hash] 墙体类型配置
  # @param offset_distance [Length] 偏移距离
  # @return [void]
  # @raise [ArgumentError] 参数无效时抛出异常
  def self.validate_wall_segment_parameters(entities, edge, wall_type, offset_distance)
    raise ArgumentError, 'entities must be Sketchup::Entities' unless entities.is_a?(Sketchup::Entities)
    raise ArgumentError, 'edge must be Sketchup::Edge' unless edge.is_a?(Sketchup::Edge)
    raise ArgumentError, 'wall_type must be Hash' unless wall_type.is_a?(Hash)
    raise ArgumentError, 'offset_distance must be Length' unless offset_distance.is_a?(Length)

    # 验证墙体类型必需字段
    required_fields = %i[name color thickness height tag]
    missing_fields = required_fields.reject { |field| wall_type.key?(field) }
    return if missing_fields.empty?

    raise ArgumentError, "wall_type missing required fields: #{missing_fields.join(', ')}"
  end

  # 计算墙体几何点
  # @param edge [Sketchup::Edge] 边对象
  # @param wall_type [Hash] 墙体类型配置
  # @param offset_distance [Length] 偏移距离
  # @return [Hash] 包含底部和顶部点的哈希
  def self.calculate_wall_geometry_points(edge, wall_type, offset_distance)
    start_point = edge.start.position
    end_point = edge.end.position

    puts "🏗️ 计算墙体几何: 起点#{start_point}, 终点#{end_point}"

    # 计算墙体方向向量
    edge_vector = end_point - start_point

    # 检查是否为零长度向量
    raise '线段长度过短，无法生成墙体' if edge_vector.length < 0.001

    edge_vector.normalize!

    # 计算垂直向量（在XY平面）
    # 检查是否为垂直线段（仅在Z轴方向）
    raise '垂直线段无法生成水平墙体' if edge_vector.x.abs < 0.001 && edge_vector.y.abs < 0.001

    perpendicular_vector = Geom::Vector3d.new(-edge_vector.y, edge_vector.x, 0)

    # 检查垂直向量是否有效
    raise '无法计算垂直向量' if perpendicular_vector.length < 0.001

    perpendicular_vector.normalize!

    # 计算底部四个角点
    bottom_points = calculate_bottom_corner_points(start_point, end_point, perpendicular_vector, offset_distance)

    # 计算顶部四个角点
    wall_height = validate_and_get_wall_height(wall_type[:height])
    top_points = calculate_top_corner_points(bottom_points, wall_height)

    {
      bottom: bottom_points,
      top: top_points
    }
  end

  # 计算底部角点
  # @param start_point [Geom::Point3d] 起始点
  # @param end_point [Geom::Point3d] 结束点
  # @param perpendicular_vector [Geom::Vector3d] 垂直向量
  # @param offset_distance [Length] 偏移距离
  # @return [Hash] 底部四个角点
  def self.calculate_bottom_corner_points(start_point, end_point, perpendicular_vector, offset_distance)
    {
      front_left: start_point.offset(perpendicular_vector, offset_distance),
      front_right: start_point.offset(perpendicular_vector, -offset_distance),
      back_right: end_point.offset(perpendicular_vector, -offset_distance),
      back_left: end_point.offset(perpendicular_vector, offset_distance)
    }
  end

  # 验证并获取墙体高度
  # @param height [Length] 墙体高度
  # @return [Length] 验证后的正值高度
  def self.validate_and_get_wall_height(height)
    height_value = height
    puts "📏 墙体高度: #{height_value} (#{height_value.to_mm}mm)"

    # 确保高度为正值，向上（正Z方向）生成
    if height_value.negative?
      height_value = -height_value
      puts "🔧 修正负高度为正值: #{height_value}"
    end

    height_value
  end

  # 计算顶部角点
  # @param bottom_points [Hash] 底部角点
  # @param wall_height [Length] 墙体高度
  # @return [Hash] 顶部四个角点
  def self.calculate_top_corner_points(bottom_points, wall_height)
    height_vector = Geom::Vector3d.new(0, 0, wall_height)

    top_points = {}
    bottom_points.each do |key, point|
      top_key = key.to_s.sub('bottom_', 'top_').to_sym
      top_points[top_key] = point.offset(height_vector)
    end

    puts "🔺 底部点高度: #{bottom_points[:front_left].z}, 顶部点高度: #{top_points[:front_left].z}"
    top_points
  end

  # 创建墙体面
  # @param entities [Sketchup::Entities] 实体集合
  # @param wall_points [Hash] 墙体点集合
  # @return [void]
  def self.create_wall_faces(entities, wall_points)
    bottom = wall_points[:bottom]
    top = wall_points[:top]

    # 创建底面
    entities.add_face(
      bottom[:front_left],
      bottom[:front_right],
      bottom[:back_right],
      bottom[:back_left]
    )

    # 创建顶面
    entities.add_face(
      top[:front_left],
      top[:back_left],
      top[:back_right],
      top[:front_right]
    )

    # 创建侧面
    create_wall_side_faces(entities, bottom, top)
  end

  # 创建墙体侧面
  # @param entities [Sketchup::Entities] 实体集合
  # @param bottom [Hash] 底部点
  # @param top [Hash] 顶部点
  # @return [void]
  def self.create_wall_side_faces(entities, bottom, top)
    # 前面
    entities.add_face(
      bottom[:front_left],
      bottom[:back_left],
      top[:back_left],
      top[:front_left]
    )

    # 左面
    entities.add_face(
      bottom[:front_right],
      bottom[:front_left],
      top[:front_left],
      top[:front_right]
    )

    # 后面
    entities.add_face(
      bottom[:back_right],
      bottom[:front_right],
      top[:front_right],
      top[:back_right]
    )

    # 右面
    entities.add_face(
      bottom[:back_left],
      bottom[:back_right],
      top[:back_right],
      top[:back_left]
    )
  end

  # 应用墙体材质（模块级方法）
  # @param wall_group [Sketchup::Group] 墙体组
  # @param wall_type [Hash] 墙体类型配置
  # @return [void]
  def self.apply_wall_material(wall_group, wall_type)
    model = Sketchup.active_model

    # 尝试找到或创建材质

    # 如果颜色是十六进制格式
    material_name = "WallMaterial_#{wall_type[:name]}"
    material = model.materials[material_name]
    if wall_type[:color].start_with?('#')
      # 创建新材质

      unless material
        material = model.materials.add(material_name)
        # 解析十六进制颜色
        hex_color = wall_type[:color][1..]
        r = hex_color[0, 2].to_i(16)
        g = hex_color[2, 2].to_i(16)
        b = hex_color[4, 2].to_i(16)
        material.color = Sketchup::Color.new(r, g, b)
      end
    else
      # 尝试使用命名颜色

      unless material
        material = model.materials.add(material_name)
        material.color = wall_type[:color]
      end
    end

    # 应用材质到所有面
    wall_group.entities.each do |entity|
      entity.material = material if entity.is_a?(Sketchup::Face)
    end
  end

  # 保存墙体属性（模块级方法）
  # @param wall_group [Sketchup::Group] 墙体组
  # @param wall_type [Hash] 墙体类型配置
  # @param center_length [Float] 中心线长度（米）
  # @param wall_side_area [Float] 墙体侧面面积（平方米）
  # @param wall_volume [Float] 墙体体积（立方米）
  # @return [void]
  def self.save_wall_attributes(wall_group, wall_type, center_length, wall_side_area, wall_volume)
    # 保存墙体类型信息
    wall_group.set_attribute('ZephyrWallData', 'wall_type_name', wall_type[:name])
    wall_group.set_attribute('ZephyrWallData', 'wall_type_color', wall_type[:color])
    wall_group.set_attribute('ZephyrWallData', 'wall_type_thickness', wall_type[:thickness].to_mm)
    wall_group.set_attribute('ZephyrWallData', 'wall_type_height', wall_type[:height].to_mm)
    wall_group.set_attribute('ZephyrWallData', 'wall_type_tag', wall_type[:tag])

    # 保存几何信息
    wall_group.set_attribute('ZephyrWallData', 'center_line_length', center_length)
    wall_group.set_attribute('ZephyrWallData', 'wall_side_area', wall_side_area)
    wall_group.set_attribute('ZephyrWallData', 'wall_volume', wall_volume)
    wall_group.set_attribute('ZephyrWallData', 'created_time', Time.now.to_s)

    # 设置Group名称
    wall_group.name = "墙体_#{wall_type[:name]}_#{Time.now.strftime('%H%M%S')}"

    # 修复单位显示问题
    center_length_mm = center_length.is_a?(Length) ? center_length.to_mm.round(1) : center_length.to_f.round(1)
    wall_side_area_m2 = wall_side_area.is_a?(Length) ? (wall_side_area.to_mm * wall_side_area.to_mm / 1_000_000).round(3) : (wall_side_area.to_f / 1_000_000).round(3)
    wall_volume_m3 = wall_volume.is_a?(Length) ? ((wall_volume.to_mm**3) / 1_000_000_000).round(6) : (wall_volume.to_f / 1_000_000_000).round(6)

    puts "保存墙体属性: #{wall_type[:name]}, 中线长度: #{center_length_mm} mm, 侧面面积: #{wall_side_area_m2} m², 墙体体积: #{wall_volume_m3} m³"
  end

  # 诊断工具：检查当前图层状态
  def self.diagnose_layer_status
    model = Sketchup.active_model

    puts '🩺 图层状态完整诊断：'
    puts '=' * 60
    puts '基本信息：'
    puts "  SketchUp版本: #{Sketchup.version}"
    puts "  当前活动图层: #{model.active_layer ? model.active_layer.name : 'nil'}"
    puts "  活动图层类型: #{model.active_layer ? model.active_layer.class : 'nil'}"
    puts "  总图层数量: #{model.layers.length}"

    puts "\n图层详细列表："
    model.layers.each_with_index do |layer, index|
      is_active = (layer == model.active_layer)
      edge_count = 0
      face_count = 0

      # 统计该图层上的实体数量
      model.active_entities.each do |entity|
        if entity.respond_to?(:layer) && entity.layer == layer
          if entity.is_a?(Sketchup::Edge)
            edge_count += 1
          elsif entity.is_a?(Sketchup::Face)
            face_count += 1
          end
        end
      end

      status = []
      status << '活动' if is_active
      status << '可见' if layer.visible?
      status << '锁定' if layer.locked?

      puts "  #{index + 1}. #{layer.name}"
      puts "     状态: #{status.empty? ? '普通' : status.join(', ')}"
      puts "     实体: #{edge_count}线段, #{face_count}面"
      puts "     对象ID: #{layer.object_id}"
    end

    puts "\n墙体相关分析："
    wall_layers = model.layers.select { |l| l.name.start_with?('墙体_') }
    if wall_layers.empty?
      puts '  ❌ 没有找到墙体图层'
    else
      puts "  ✅ 找到 #{wall_layers.length} 个墙体图层"
      wall_layers.each do |layer|
        is_active = (layer == model.active_layer)
        puts "    #{layer.name} #{is_active ? '(当前活动)' : ''}"
      end
    end

    puts "\n当前选中实体："
    selection = model.selection
    if selection.empty?
      puts '  无选中实体'
    else
      selection.each_with_index do |entity, index|
        layer_name = entity.respond_to?(:layer) ? entity.layer.name : 'N/A'
        puts "  #{index + 1}. #{entity.class} (图层: #{layer_name})"
      end
    end

    puts '=' * 60
    puts '诊断完成'

    # 返回状态摘要
    {
      active_layer: model.active_layer&.name,
      total_layers: model.layers.length,
      wall_layers: wall_layers.length,
      has_active_wall_layer: wall_layers.any? { |l| l == model.active_layer }
    }
  end

  # 快速检查工具
  def self.quick_layer_check
    model = Sketchup.active_model
    current = model.active_layer

    puts '📋 快速图层检查：'
    puts "  当前: #{current ? current.name : 'nil'}"
    puts "  是否墙体图层: #{current&.name&.start_with?('墙体_') ? '是' : '否'}"

    current&.name
  end

  # 专门用于追踪图层切换问题的诊断工具
  def self.diagnose_layer_switching_issue
    model = Sketchup.active_model

    puts '🔬 图层切换问题专项诊断：'
    puts '=' * 60

    # 基本状态
    current_layer = model.active_layer
    puts "当前活动图层: #{current_layer ? current_layer.name : 'nil'}"
    puts "当前图层可见: #{current_layer ? current_layer.visible? : 'N/A'}"
    puts "当前图层锁定: #{current_layer ? current_layer.locked? : 'N/A'}"

    # 检查所有墙体图层
    wall_layers = model.layers.select { |l| l.name.start_with?('墙体_') }
    puts "\n墙体图层状态："
    wall_layers.each do |layer|
      is_active = (layer == current_layer)
      puts "  #{layer.name}:"
      puts "    活动: #{is_active}"
      puts "    可见: #{layer.visible?}"
      puts "    锁定: #{layer.locked?}"
      puts "    对象ID: #{layer.object_id}"
    end

    # 测试切换行为
    puts "\n测试图层切换行为："
    if wall_layers.length.positive?
      test_layer = wall_layers.first
      puts "测试切换到: #{test_layer.name}"

      # 记录切换前状态
      before_switch = model.active_layer
      puts "  切换前: #{before_switch ? before_switch.name : 'nil'}"

      # 执行切换
      begin
        model.active_layer = test_layer
        after_switch = model.active_layer
        puts "  切换后: #{after_switch ? after_switch.name : 'nil'}"
        puts "  切换成功: #{after_switch == test_layer}"

        # 测试可见性影响
        puts "\n测试可见性设置的影响："
        original_visibility = test_layer.visible?

        # 设置为不可见
        test_layer.visible = false
        after_hide = model.active_layer
        puts "  设为不可见后活动图层: #{after_hide ? after_hide.name : 'nil'}"

        # 恢复可见性
        test_layer.visible = original_visibility
        after_show = model.active_layer
        puts "  恢复可见后活动图层: #{after_show ? after_show.name : 'nil'}"
      rescue StandardError => e
        puts "  测试出错: #{e.message}"
      end
    end

    puts '=' * 60
    puts '诊断完成'
  end

  # 获取增强的墙体统计（重构后的主方法）
  # @return [Hash] 包含按类型和总计的统计数据
  def self.get_enhanced_wall_statistics
    model = Sketchup.active_model
    entities = model.active_entities

    wall_groups = find_all_wall_groups(entities)

    return create_empty_statistics if wall_groups.empty?

    wall_stats_by_type = {}
    total_stats = initialize_total_statistics

    wall_groups.each do |wall_group|
      wall_data = extract_wall_data(wall_group)
      next unless wall_data

      update_type_statistics(wall_stats_by_type, wall_data)
      update_total_statistics(total_stats, wall_data)
    end

    {
      by_type: wall_stats_by_type,
      total: total_stats
    }
  end

  # 查找所有墙体组
  # @param entities [Sketchup::Entities] 实体集合
  # @return [Array<Sketchup::Group>] 墙体组数组
  def self.find_all_wall_groups(entities)
    entities.select do |entity|
      entity.is_a?(Sketchup::Group) &&
        entity.get_attribute('ZephyrWallData', 'wall_type_name')
    end
  end

  # 创建空统计数据
  # @return [Hash] 空的统计数据结构
  def self.create_empty_statistics
    {
      by_type: {},
      total: {
        count: 0,
        total_length: 0.0,
        total_side_area: 0.0,
        total_volume: 0.0
      }
    }
  end

  # 初始化总计统计
  # @return [Hash] 初始化的总计统计数据
  def self.initialize_total_statistics
    {
      count: 0,
      total_length: 0.0,
      total_side_area: 0.0,
      total_volume: 0.0
    }
  end

  # 提取墙体数据
  # @param wall_group [Sketchup::Group] 墙体组
  # @return [Hash, nil] 墙体数据或 nil
  def self.extract_wall_data(wall_group)
    wall_type_name = wall_group.get_attribute('ZephyrWallData', 'wall_type_name')
    return nil unless wall_type_name

    # 🔧 增强：使用SketchUp Entity Info数据获取精确尺寸
    entity_info = get_entity_info_data(wall_group)

    # 优先使用Entity Info的数据，如果没有则使用存储的数据
    center_length = entity_info[:length] ||
                    wall_group.get_attribute('ZephyrWallData', 'center_line_length') || 0.0
    wall_side_area = entity_info[:area] ||
                     wall_group.get_attribute('ZephyrWallData', 'wall_side_area') || 0.0
    wall_volume = entity_info[:volume] ||
                  wall_group.get_attribute('ZephyrWallData', 'wall_volume') || 0.0

    {
      type_name: wall_type_name,
      center_length: center_length,
      wall_side_area: wall_side_area,
      wall_volume: wall_volume,
      entity_info: entity_info,
      wall_type: extract_wall_type_info(wall_group)
    }
  end

  # 提取墙体类型信息
  # @param wall_group [Sketchup::Group] 墙体组
  # @return [Hash] 墙体类型信息
  def self.extract_wall_type_info(wall_group)
    {
      name: wall_group.get_attribute('ZephyrWallData', 'wall_type_name'),
      color: wall_group.get_attribute('ZephyrWallData', 'wall_type_color'),
      thickness: wall_group.get_attribute('ZephyrWallData', 'wall_type_thickness'),
      height: wall_group.get_attribute('ZephyrWallData', 'wall_type_height'),
      tag: wall_group.get_attribute('ZephyrWallData', 'wall_type_tag')
    }
  end

  # 更新类型统计
  # @param wall_stats_by_type [Hash] 按类型的统计数据
  # @param wall_data [Hash] 墙体数据
  # @return [void]
  def self.update_type_statistics(wall_stats_by_type, wall_data)
    type_name = wall_data[:type_name]

    # 初始化类型统计（如果不存在）
    wall_stats_by_type[type_name] ||= initialize_type_statistics(wall_data)

    # 累加统计数据
    stats = wall_stats_by_type[type_name]
    stats[:count] += 1
    stats[:total_length] += wall_data[:center_length]
    stats[:total_side_area] += wall_data[:wall_side_area]
    stats[:total_volume] += wall_data[:wall_volume]

    # 累加Entity Info数据
    entity_info = wall_data[:entity_info]
    stats[:entity_info_length] += entity_info[:length] || 0.0
    stats[:entity_info_area] += entity_info[:area] || 0.0
    stats[:entity_info_volume] += entity_info[:volume] || 0.0
  end

  # 初始化类型统计
  # @param wall_data [Hash] 墙体数据
  # @return [Hash] 初始化的类型统计数据
  def self.initialize_type_statistics(wall_data)
    {
      count: 0,
      total_length: 0.0,
      total_side_area: 0.0,
      total_volume: 0.0,
      entity_info_length: 0.0,
      entity_info_area: 0.0,
      entity_info_volume: 0.0,
      wall_type: wall_data[:wall_type]
    }
  end

  # 更新总计统计
  # @param total_stats [Hash] 总计统计数据
  # @param wall_data [Hash] 墙体数据
  # @return [void]
  def self.update_total_statistics(total_stats, wall_data)
    total_stats[:count] += 1
    total_stats[:total_length] += wall_data[:center_length]
    total_stats[:total_side_area] += wall_data[:wall_side_area]
    total_stats[:total_volume] += wall_data[:wall_volume]
  end

  # 修复：获取Entity Info数据（模拟SketchUp的Entity Info面板数据）
  def self.get_entity_info_data(entity)
    return {} unless entity.is_a?(Sketchup::Group)

    info = {}

    begin
      # 获取边界框信息
      bounds = entity.bounds
      if bounds.valid?
        # 🔧 修复：正确计算尺寸
        width_mm = bounds.width.to_mm
        height_mm = bounds.height.to_mm
        depth_mm = bounds.depth.to_mm

        width_m = width_mm / 1000.0
        height_m = height_mm / 1000.0
        depth_m = depth_mm / 1000.0

        # 对于墙体，长度通常是水平方向的最大尺寸
        horizontal_length = [width_m, depth_m].max
        info[:length] = horizontal_length

        puts "📏 Entity Info - 墙体尺寸: #{width_m.round(3)}m x #{depth_m.round(3)}m x #{height_m.round(3)}m"
        puts "📏 Entity Info - 原始尺寸: #{width_mm.round(1)}mm x #{depth_mm.round(1)}mm x #{height_mm.round(1)}mm"
        puts "📏 Entity Info - 检测长度: #{horizontal_length.round(3)}m"
      end

      # 计算实际几何面积和体积
      info[:area] = calculate_real_wall_area(entity)
      info[:volume] = calculate_real_wall_volume(entity)

      # 如果有子几何体，也计算它们的信息
      total_face_area = 0.0
      entity.entities.each do |sub_entity|
        next unless sub_entity.is_a?(Sketchup::Face)

        # 转换面积单位：从平方英寸到平方米
        face_area_sqm = sub_entity.area * 0.00064516
        total_face_area += face_area_sqm
      end

      info[:total_face_area] = total_face_area
      puts "📏 Entity Info - 总面积: #{total_face_area.round(3)}m²"
    rescue StandardError => e
      puts "获取Entity Info数据时出错: #{e.message}"
    end

    info
  end

  # 显示增强的墙体统计对话框（使用Entity Info数据）
  # @return [void]
  def self.show_enhanced_wall_statistics
    stats = get_enhanced_wall_statistics

    if stats[:total][:count].zero?
      UI.messagebox('模型中没有找到墙体数据')
      return
    end

    # 创建增强的统计报告
    report = "=== 增强墙体统计报告 ===\n"
    report += "📏 集成SketchUp Entity Info数据\n\n"

    # 按类型统计
    stats[:by_type].each do |type_name, data|
      wall_type = data[:wall_type]
      report += "🏗️ 类型: #{type_name}\n"
      report += "  数量: #{data[:count]} 个\n"

      # 🔧 新增：Entity Info长度对比
      stored_length = data[:total_length]
      entity_length = data[:entity_info_length]
      if entity_length.positive?
        report += "  📏 长度 (Entity Info): #{entity_length.round(3)} m\n"
        if stored_length.positive?
          report += "  📏 长度 (存储数据): #{stored_length.round(3)} m\n"
          diff = ((entity_length - stored_length).abs / stored_length * 100).round(1)
          report += "  ⚠️  长度差异: #{diff}%\n" if diff > 5
        end
      else
        report += "  📏 长度: #{stored_length.round(3)} m\n"
      end

      # 🔧 新增：Entity Info面积对比
      stored_area = data[:total_side_area]
      entity_area = data[:entity_info_area]
      if entity_area.positive?
        report += "  📐 面积 (Entity Info): #{entity_area.round(3)} m²\n"
        report += "  📐 面积 (存储数据): #{stored_area.round(3)} m²\n" if stored_area.positive?
      else
        report += "  📐 面积: #{stored_area.round(3)} m²\n"
      end

      # 🔧 新增：Entity Info体积对比
      stored_volume = data[:total_volume]
      entity_volume = data[:entity_info_volume]
      if entity_volume.positive?
        report += "  📦 体积 (Entity Info): #{entity_volume.round(4)} m³\n"
        report += "  📦 体积 (存储数据): #{stored_volume.round(4)} m³\n" if stored_volume.positive?
      else
        report += "  📦 体积: #{stored_volume.round(4)} m³\n"
      end

      report += "  📋 规格:\n"
      report += "    • 厚度: #{wall_type[:thickness]} mm\n"
      report += "    • 高度: #{wall_type[:height]} mm\n"
      report += "    • 标签: #{wall_type[:tag]}\n"
      report += "    • 颜色: #{wall_type[:color]}\n"
      report += "\n"
    end

    # 总计
    report += "=== 📊 项目总计 ===\n"
    report += "墙体总数: #{stats[:total][:count]} 个\n"

    # 🔧 修复 Length 对象求和问题 (#1024)
    # 使用 reduce 替代 sum 方法，确保类型安全
    total_entity_length = calculate_safe_length_sum(stats[:by_type], :entity_info_length)
    total_entity_area = calculate_safe_area_sum(stats[:by_type], :entity_info_area)
    total_entity_volume = calculate_safe_volume_sum(stats[:by_type], :entity_info_volume)

    report += "总长度 (Entity Info): #{total_entity_length.round(3)} m\n" if total_entity_length.positive?
    report += "总长度 (存储数据): #{stats[:total][:total_length].round(3)} m\n"

    report += "总面积 (Entity Info): #{total_entity_area.round(3)} m²\n" if total_entity_area.positive?
    report += "总面积 (存储数据): #{stats[:total][:total_side_area].round(3)} m²\n"

    report += "总体积 (Entity Info): #{total_entity_volume.round(4)} m³\n" if total_entity_volume.positive?
    report += "总体积 (存储数据): #{stats[:total][:total_volume].round(4)} m³\n"

    report += "\n💡 提示:\n"
    report += "• Entity Info数据来自SketchUp几何测量\n"
    report += "• 存储数据来自插件计算的理论值\n"
    report += "• 如有较大差异，建议检查墙体生成质量\n"

    # 显示报告
    UI.messagebox(report, MB_OK, '增强墙体统计报告')
  end

  # 安全计算长度总和（修复 Length 对象求和问题 #1024）
  # @param stats_by_type [Hash] 按类型的统计数据
  # @param field_key [Symbol] 要求和的字段键
  # @return [Float] 长度总和（米）
  def self.calculate_safe_length_sum(stats_by_type, field_key)
    stats_by_type.values.reduce(0.0) do |sum, data|
      length_value = data[field_key] || 0.0
      # 确保类型安全：如果是 Length 对象，转换为米；否则当作数值处理
      numeric_value = length_value.is_a?(Length) ? length_value.to_m : length_value.to_f
      sum + numeric_value
    end
  end

  # 安全计算面积总和
  # @param stats_by_type [Hash] 按类型的统计数据
  # @param field_key [Symbol] 要求和的字段键
  # @return [Float] 面积总和（平方米）
  def self.calculate_safe_area_sum(stats_by_type, field_key)
    stats_by_type.values.reduce(0.0) do |sum, data|
      area_value = data[field_key] || 0.0
      sum + area_value.to_f
    end
  end

  # 安全计算体积总和
  # @param stats_by_type [Hash] 按类型的统计数据
  # @param field_key [Symbol] 要求和的字段键
  # @return [Float] 体积总和（立方米）
  def self.calculate_safe_volume_sum(stats_by_type, field_key)
    stats_by_type.values.reduce(0.0) do |sum, data|
      volume_value = data[field_key] || 0.0
      sum + volume_value.to_f
    end
  end

  # 🆕 v1.3.2 新增：直接从SketchUp系统获取Entity Info数据的方法
  def self.get_native_entity_info_data(entity)
    return {} unless entity.respond_to?(:bounds)

    info = {}
    puts '🔍 获取SketchUp原生Entity Info数据：'
    puts "  实体类型: #{entity.class}"

    begin
      # 方法1：获取边界框（BoundingBox）- SketchUp原生
      bounds = entity.bounds
      if bounds.valid?
        puts '  ✅ 边界框有效'

        # 获取原生尺寸（SketchUp Length对象）
        native_width = bounds.width      # 返回Length对象
        native_height = bounds.height    # 返回Length对象
        native_depth = bounds.depth      # 返回Length对象

        puts '  📏 原生尺寸 (Length对象):'
        puts "    Width: #{native_width}"
        puts "    Height: #{native_height}"
        puts "    Depth: #{native_depth}"

        # 转换为标准单位（米）
        width_m = native_width.to_m
        height_m = native_height.to_m
        depth_m = native_depth.to_m

        puts '  📏 转换为米:'
        puts "    Width: #{width_m.round(4)}m"
        puts "    Height: #{height_m.round(4)}m"
        puts "    Depth: #{depth_m.round(4)}m"

        # 智能识别墙体方向和长度
        # 通常墙体的高度是Z方向，长度是水平方向的最大值
        horizontal_dimensions = [width_m, depth_m]
        wall_length = horizontal_dimensions.max
        wall_thickness = horizontal_dimensions.min
        wall_height = height_m

        info[:native_length] = wall_length
        info[:native_thickness] = wall_thickness
        info[:native_height] = wall_height

        puts '  🏗️ 墙体识别:'
        puts "    长度: #{wall_length.round(4)}m"
        puts "    厚度: #{wall_thickness.round(4)}m"
        puts "    高度: #{wall_height.round(4)}m"

        # 计算原生体积（边界框体积）
        native_volume = native_width.to_m * native_height.to_m * native_depth.to_m
        info[:native_volume] = native_volume
        puts "  📦 边界框体积: #{native_volume.round(4)}m³"

      else
        puts '  ❌ 边界框无效'
      end

      # 方法2：获取实体的直接面积（如果是Group或Component）
      if entity.respond_to?(:entities)
        total_face_area = 0.0
        vertical_face_area = 0.0
        horizontal_face_area = 0.0
        face_count = 0

        puts '  🔍 分析内部几何体：'

        entity.entities.each do |sub_entity|
          next unless sub_entity.is_a?(Sketchup::Face)

          face_count += 1

          # 获取面的原生面积（平方英寸）
          face_area_sqinch = sub_entity.area

          # 转换为平方米
          face_area_sqm = face_area_sqinch * 0.00064516
          total_face_area += face_area_sqm

          # 分析面的方向
          normal = sub_entity.normal
          if normal.z.abs < 0.1
            # 垂直面（墙体侧面）
            vertical_face_area += face_area_sqm
            puts "    垂直面 #{face_count}: #{face_area_sqm.round(4)}m² (法向量: #{normal})"
          else
            # 水平面（顶面/底面）
            horizontal_face_area += face_area_sqm
            puts "    水平面 #{face_count}: #{face_area_sqm.round(4)}m² (法向量: #{normal})"
          end
        end

        info[:native_total_area] = total_face_area
        info[:native_wall_area] = vertical_face_area
        info[:native_horizontal_area] = horizontal_face_area
        info[:face_count] = face_count

        puts '  📐 面积统计:'
        puts "    总面积: #{total_face_area.round(4)}m²"
        puts "    墙体面积: #{vertical_face_area.round(4)}m²"
        puts "    水平面积: #{horizontal_face_area.round(4)}m²"
        puts "    面数量: #{face_count}"

        # 对于墙体，我们通常关心单面墙体面积
        if vertical_face_area.positive?
          # 如果有多个垂直面，可能是内外两面，取一半作为单面面积
          estimated_single_wall_area = vertical_face_area / 2.0
          info[:native_single_wall_area] = estimated_single_wall_area
          puts "  🎯 估算单面墙体面积: #{estimated_single_wall_area.round(4)}m²"
        end
      end

      # 方法3：如果支持，获取质量属性（某些SketchUp版本）
      if entity.respond_to?(:volume) && entity.volume
        native_volume_direct = entity.volume.to_m * entity.volume.to_m * entity.volume.to_m
        info[:native_volume_direct] = native_volume_direct
        puts "  📦 直接体积: #{native_volume_direct.round(4)}m³"
      end
    rescue StandardError => e
      puts "  ❌ 获取原生数据时出错: #{e.message}"
    end

    puts '  ✅ 原生Entity Info数据获取完成'
    info
  end

  # 🆕 对比原生数据与插件数据的统计报告
  def self.show_native_vs_plugin_statistics
    model = Sketchup.active_model
    model.active_entities

    if model.selection.empty?
      UI.messagebox('请先选择一个或多个墙体Group，然后运行此命令')
      return
    end

    selected_walls = model.selection.select do |entity|
      entity.is_a?(Sketchup::Group) && entity.get_attribute('ZephyrWallData', 'wall_type_name')
    end

    if selected_walls.empty?
      UI.messagebox('选中的实体中没有墙体Group')
      return
    end

    report = "=== SketchUp原生数据 vs 插件数据对比 ===\n\n"
    report += "🔍 分析选中的 #{selected_walls.length} 个墙体\n\n"

    selected_walls.each_with_index do |wall_group, index|
      wall_name = wall_group.get_attribute('ZephyrWallData', 'wall_type_name') || '未知墙体'
      report += "🏗️ 墙体 #{index + 1}: #{wall_name}\n"
      report += "   Group名称: #{wall_group.name}\n\n"

      # 获取插件存储的数据
      plugin_length = wall_group.get_attribute('ZephyrWallData', 'center_line_length') || 0.0
      plugin_area = wall_group.get_attribute('ZephyrWallData', 'wall_side_area') || 0.0
      plugin_volume = wall_group.get_attribute('ZephyrWallData', 'wall_volume') || 0.0
      plugin_thickness = wall_group.get_attribute('ZephyrWallData', 'wall_type_thickness') || 0.0
      plugin_height = wall_group.get_attribute('ZephyrWallData', 'wall_type_height') || 0.0

      # 获取SketchUp原生数据
      native_data = get_native_entity_info_data(wall_group)

      # 📏 长度对比
      report += "📏 长度对比:\n"
      report += "   插件数据: #{plugin_length.round(3)}m\n"
      if native_data[:native_length]
        native_length = native_data[:native_length]
        report += "   SketchUp原生: #{native_length.round(3)}m\n"
        if plugin_length.positive?
          length_diff = ((native_length - plugin_length).abs / plugin_length * 100).round(1)
          report += "   差异: #{length_diff}%\n"
        end
      else
        report += "   SketchUp原生: 无法获取\n"
      end
      report += "\n"

      # 📐 面积对比
      report += "📐 面积对比:\n"
      report += "   插件数据: #{plugin_area.round(3)}m²\n"
      if native_data[:native_single_wall_area]
        native_area = native_data[:native_single_wall_area]
        report += "   SketchUp原生(单面): #{native_area.round(3)}m²\n"
        if plugin_area.positive?
          area_diff = ((native_area - plugin_area).abs / plugin_area * 100).round(1)
          report += "   差异: #{area_diff}%\n"
        end
      elsif native_data[:native_wall_area]
        native_wall_area = native_data[:native_wall_area]
        report += "   SketchUp原生(总墙面): #{native_wall_area.round(3)}m²\n"
      else
        report += "   SketchUp原生: 无法获取\n"
      end
      report += "\n"

      # 📦 体积对比
      report += "📦 体积对比:\n"
      report += "   插件数据: #{plugin_volume.round(4)}m³\n"
      if native_data[:native_volume]
        native_volume = native_data[:native_volume]
        report += "   SketchUp原生: #{native_volume.round(4)}m³\n"
        if plugin_volume.positive?
          volume_diff = ((native_volume - plugin_volume).abs / plugin_volume * 100).round(1)
          report += "   差异: #{volume_diff}%\n"
        end
      else
        report += "   SketchUp原生: 无法获取\n"
      end
      report += "\n"

      # 📏 尺寸对比
      report += "📏 尺寸对比:\n"
      report += "   插件厚度: #{plugin_thickness}mm\n"
      report += "   插件高度: #{plugin_height}mm\n"
      if native_data[:native_thickness] && native_data[:native_height]
        native_thickness_mm = (native_data[:native_thickness] * 1000).round(1)
        native_height_mm = (native_data[:native_height] * 1000).round(1)
        report += "   SketchUp厚度: #{native_thickness_mm}mm\n"
        report += "   SketchUp高度: #{native_height_mm}mm\n"
      end
      report += "\n"

      # 💡 数据源可靠性建议
      if native_data[:face_count]&.positive?
        report += "💡 建议:\n"
        if native_data[:native_length] && (plugin_length - native_data[:native_length]).abs < 0.01
          report += "   ✅ 长度数据一致性良好\n"
        elsif native_data[:native_length]
          report += "   ⚠️  建议使用SketchUp原生长度数据\n"
        end

        if native_data[:native_single_wall_area] && (plugin_area - native_data[:native_single_wall_area]).abs < 0.1
          report += "   ✅ 面积数据一致性良好\n"
        elsif native_data[:native_single_wall_area]
          report += "   ⚠️  建议使用SketchUp原生面积数据\n"
        end
      end

      report += "\n#{'=' * 50}\n\n"
    end

    report += "📋 数据获取说明:\n"
    report += "• SketchUp原生数据：直接从几何体边界框和面计算\n"
    report += "• 插件数据：基于墙体类型参数和中线长度计算\n"
    report += "• 建议：优先使用一致性好的数据源\n"

    # 显示报告
    UI.messagebox(report, MB_OK, '原生数据对比分析')
  end

  # 🆕 使用纯SketchUp原生数据更新墙体属性
  def self.update_wall_with_native_data
    model = Sketchup.active_model

    if model.selection.empty?
      UI.messagebox('请先选择一个墙体Group')
      return
    end

    selected_entity = model.selection.first
    unless selected_entity.is_a?(Sketchup::Group) && selected_entity.get_attribute('ZephyrWallData', 'wall_type_name')
      UI.messagebox('请选择一个墙体Group')
      return
    end

    # 获取原生数据
    native_data = get_native_entity_info_data(selected_entity)

    if native_data.empty?
      UI.messagebox('无法获取该墙体的SketchUp原生数据')
      return
    end

    # 确认更新
    confirmation = "确定要使用SketchUp原生数据更新墙体属性吗？\n\n"
    confirmation += "原生数据:\n"
    confirmation += "• 长度: #{native_data[:native_length] ? "#{native_data[:native_length].round(3)}m" : '无'}\n"
    confirmation += "• 面积: #{native_data[:native_single_wall_area] ? "#{native_data[:native_single_wall_area].round(3)}m²" : '无'}\n"
    confirmation += "• 体积: #{native_data[:native_volume] ? "#{native_data[:native_volume].round(4)}m³" : '无'}\n"

    result = UI.messagebox(confirmation, MB_YESNO)
    return unless result == IDYES

    # 开始更新
    model.start_operation('使用原生数据更新墙体', true)

    begin
      # 更新属性
      selected_entity.set_attribute('ZephyrWallData', 'center_line_length', native_data[:native_length]) if native_data[:native_length]

      if native_data[:native_single_wall_area]
        selected_entity.set_attribute('ZephyrWallData', 'wall_side_area', native_data[:native_single_wall_area])
      end

      selected_entity.set_attribute('ZephyrWallData', 'wall_volume', native_data[:native_volume]) if native_data[:native_volume]

      # 更新时间戳
      selected_entity.set_attribute('ZephyrWallData', 'last_native_update', Time.now.to_s)
      selected_entity.set_attribute('ZephyrWallData', 'uses_native_data', true)

      model.commit_operation

      UI.messagebox("墙体属性已使用SketchUp原生数据更新！\n\n现在的统计报告将显示更准确的数据。")
    rescue StandardError => e
      model.abort_operation
      puts "更新墙体原生数据时出错: #{e.message}"
      UI.messagebox("更新失败: #{e.message}")
    end
  end

  # 🆕 批量使用原生数据更新所有墙体（优化版本）
  def self.batch_update_walls_with_native_data
    MemoryManager.with_memory_optimization(enable_gc: true) do
      model = Sketchup.active_model
      entities = model.active_entities

      # 查找所有墙体
      wall_groups = find_all_wall_groups(entities)

      if wall_groups.empty?
        UI.messagebox('模型中没有找到墙体')
        return
      end

      # 确认批量更新
      result = UI.messagebox(
        "找到 #{wall_groups.length} 个墙体。\n\n确定要批量使用SketchUp原生数据更新所有墙体吗？\n\n这将:\n• 用边界框数据更新长度\n• 用几何面积更新墙体面积\n• 用边界框体积更新体积\n\n原有的插件计算数据将被覆盖。",
        MB_YESNO,
        '批量更新确认'
      )
      return unless result == IDYES

      # 使用批量操作管理器
      operation_manager.execute_batch_operation('批量更新墙体原生数据', wall_groups) do |wall_group, _index, _op_manager|
        wall_name = wall_group.get_attribute('ZephyrWallData', 'wall_type_name') || '未命名墙体'

        RecoveryHelper.with_recovery(operation_name: "更新墙体 #{wall_name}") do
          # 获取原生数据
          native_data = get_native_entity_info_data(wall_group)

          if native_data.empty?
            puts '  跳过：无法获取原生数据'
            raise StandardError, '无法获取原生数据'
          end

          # 更新属性
          update_wall_native_attributes(wall_group, native_data)

          puts "  ✅ 更新成功: #{wall_name}"
        end
      end

      # 强制UI刷新
      UIRefreshManager.request_refresh(force: true)

      puts '✅ 批量更新完成！所有墙体现在使用SketchUp原生数据。'
    end
  rescue StandardError => e
    ErrorManager.handle_error(
      e,
      context: '批量更新墙体原生数据',
      type: :api_error,
      operation: 'batch_update_walls_with_native_data'
    )
  end

  # 更新墙体原生属性
  # @param wall_group [Sketchup::Group] 墙体组
  # @param native_data [Hash] 原生数据
  # @return [void]
  def self.update_wall_native_attributes(wall_group, native_data)
    # 更新长度
    wall_group.set_attribute('ZephyrWallData', 'center_line_length', native_data[:native_length]) if native_data[:native_length]

    # 更新面积
    if native_data[:native_single_wall_area]
      wall_group.set_attribute('ZephyrWallData', 'wall_side_area', native_data[:native_single_wall_area])
    elsif native_data[:native_wall_area]
      # 如果没有单面面积，使用总墙面面积的一半
      estimated_single_area = native_data[:native_wall_area] / 2.0
      wall_group.set_attribute('ZephyrWallData', 'wall_side_area', estimated_single_area)
    end

    # 更新体积
    wall_group.set_attribute('ZephyrWallData', 'wall_volume', native_data[:native_volume]) if native_data[:native_volume]

    # 标记为使用原生数据
    wall_group.set_attribute('ZephyrWallData', 'last_native_update', Time.now.to_s)
    wall_group.set_attribute('ZephyrWallData', 'uses_native_data', true)
  end

  # 🆕 简化的墙体面积计算：中线长度 × 高度
  def self.calculate_wall_area_simple(center_length_m, wall_type)
    height_m = wall_type[:height].to_m
    area_sqm = center_length_m * height_m

    puts '📐 简化面积计算：'
    puts "   中线长度: #{center_length_m.round(2)}m"
    puts "   墙体高度: #{height_m.round(2)}m"
    puts "   理论面积: #{area_sqm.round(2)}m²"

    area_sqm.round(2)
  end

  # 获取系统单位格式
  def self.get_system_units
    model = Sketchup.active_model
    # 获取模型单位设置
    units = model.options['UnitsOptions']['LengthUnit']
    precision = model.options['UnitsOptions']['LengthPrecision']

    puts "🔧 系统单位: #{units}, 精度: #{precision}"

    {
      unit: units,
      precision: precision
    }
  end

  # 格式化长度值为系统单位
  def self.format_length_to_system_units(length_value)
    model = Sketchup.active_model

    # 使用SketchUp内置的格式化方法
    if length_value.is_a?(Length)
      # 如果已经是Length对象，直接格式化
      formatted = model.options['UnitsOptions'].format_length(length_value)
    else
      # 如果是数值，先转换为Length对象
      length_obj = length_value.to_l
      formatted = model.options['UnitsOptions'].format_length(length_obj)
    end

    formatted
  end

  # 创建材质推荐对话框
  # @param wall_type [Hash] 墙体类型
  # @param recommendations [Array<Hash>] 推荐材质列表
  # @return [void]
  def self.create_material_recommendation_dialog(wall_type, recommendations)
    html_content = generate_material_recommendation_html(wall_type, recommendations)

    dialog = UI::WebDialog.new('智能材质推荐', false, 'MaterialRecommendation', 700, 500)
    dialog.set_html(html_content)

    # 设置回调
    setup_material_recommendation_callbacks(dialog, wall_type)

    dialog.show
  end

  # 生成材质推荐HTML
  # @param wall_type [Hash] 墙体类型
  # @param recommendations [Array<Hash>] 推荐材质列表
  # @return [String] HTML内容
  def self.generate_material_recommendation_html(wall_type, recommendations)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>智能材质推荐</title>
        <style>
          body {#{' '}
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;#{' '}
            margin: 0; padding: 20px; background: #f5f5f5;#{' '}
          }
          .header {#{' '}
            background: white; border-radius: 8px; padding: 20px; margin-bottom: 20px;#{' '}
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .wall-info {#{' '}
            background: #f8f9fa; border-radius: 8px; padding: 15px; margin-bottom: 20px;
            border-left: 4px solid #007AFF;
          }
          .recommendations-grid {#{' '}
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));#{' '}
            gap: 15px; margin-bottom: 20px;#{' '}
          }
          .recommendation-card {#{' '}
            background: white; border-radius: 8px; padding: 20px; text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            border: 2px solid transparent;
          }
          .recommendation-card:hover {#{' '}
            transform: translateY(-2px);#{' '}
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);#{' '}
          }
          .recommendation-card.selected {#{' '}
            border-color: #007AFF;#{' '}
            background: #f0f8ff;#{' '}
          }
          .material-color {#{' '}
            width: 60px; height: 60px; border-radius: 50%; margin: 0 auto 15px;#{' '}
            border: 3px solid #ddd;
          }
          .material-name { font-size: 16px; font-weight: 600; margin-bottom: 5px; }
          .material-category { font-size: 12px; color: #666; margin-bottom: 10px; }
          .recommendation-reason {#{' '}
            font-size: 11px; color: #007AFF; background: #f0f8ff;#{' '}
            padding: 4px 8px; border-radius: 12px; display: inline-block;
          }
          .actions {#{' '}
            background: white; border-radius: 8px; padding: 20px;#{' '}
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          .btn {#{' '}
            padding: 12px 20px; margin: 5px; border: none; border-radius: 6px;#{' '}
            cursor: pointer; font-weight: 500; transition: all 0.2s ease;
          }
          .btn-primary { background: #007AFF; color: white; }
          .btn-primary:hover { background: #0056CC; }
          .btn-primary:disabled { background: #ccc; cursor: not-allowed; }
          .btn-secondary { background: #f0f0f0; color: #333; }
          .btn-secondary:hover { background: #e0e0e0; }
          .btn-success { background: #34C759; color: white; }
          .btn-success:hover { background: #28A745; }
          .selected-material {#{' '}
            background: #f8f9fa; border-radius: 8px; padding: 15px; margin-top: 15px;
            border-left: 4px solid #34C759; display: none;
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>🎨 智能材质推荐</h1>
          <p>基于墙体类型特征，为您推荐最适合的材质</p>
        </div>
      #{'  '}
        <div class="wall-info">
          <h3>墙体类型信息</h3>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px;">
            <div><strong>名称:</strong> #{wall_type[:name]}</div>
            <div><strong>厚度:</strong> #{wall_type[:thickness].to_mm.round(1)}mm</div>
            <div><strong>高度:</strong> #{wall_type[:height].to_mm.round(1)}mm</div>
            <div><strong>标签:</strong> #{wall_type[:tag] || '无'}</div>
          </div>
        </div>
      #{'  '}
        <div class="recommendations-grid">
          #{recommendations.map.with_index { |rec, index| generate_recommendation_card_html(rec, index) }.join}
        </div>
      #{'  '}
        <div id="selected-material" class="selected-material">
          <h4>✅ 已选择材质</h4>
          <div id="material-details"></div>
        </div>
      #{'  '}
        <div class="actions">
          <h3>应用选项</h3>
          <button class="btn btn-primary" id="applyToType" onclick="applyToWallType()" disabled>
            应用到所有 "#{wall_type[:name]}" 类型墙体
          </button>
          <button class="btn btn-success" onclick="applyToSelected()">应用到选中墙体</button>
          <button class="btn btn-secondary" onclick="openMaterialLibrary()">打开材质库</button>
          <button class="btn btn-secondary" onclick="saveAsPreset()">保存为预设</button>
        </div>
      #{'  '}
        <script>
          let selectedMaterial = null;
      #{'    '}
          function selectMaterial(materialData, cardIndex) {
            selectedMaterial = materialData;
      #{'      '}
            // 更新UI
            document.querySelectorAll('.recommendation-card').forEach(card => {
              card.classList.remove('selected');
            });
            document.getElementById('card-' + cardIndex).classList.add('selected');
      #{'      '}
            // 显示选中的材质信息
            showSelectedMaterial(materialData);
      #{'      '}
            // 启用按钮
            document.getElementById('applyToType').disabled = false;
          }
      #{'    '}
          function showSelectedMaterial(materialData) {
            const container = document.getElementById('selected-material');
            const details = document.getElementById('material-details');
      #{'      '}
            details.innerHTML = `
              <div style="display: flex; align-items: center; gap: 15px;">
                <div class="material-color" style="background-color: ${materialData.color}; width: 40px; height: 40px;"></div>
                <div>
                  <div style="font-weight: 600; font-size: 16px;">${materialData.name}</div>
                  <div style="font-size: 12px; color: #666;">分类: ${materialData.category}</div>
                  <div style="font-size: 12px; color: #007AFF; margin-top: 5px;">
                    推荐原因: ${getRecommendationReason(materialData)}
                  </div>
                </div>
              </div>
            `;
      #{'      '}
            container.style.display = 'block';
          }
      #{'    '}
          function getRecommendationReason(materialData) {
            // 简化的推荐原因逻辑
            const thickness = #{wall_type[:thickness].to_mm};
            const wallName = "#{wall_type[:name]}".toLowerCase();
      #{'      '}
            if (thickness < 100) {
              return "适合薄墙体";
            } else if (thickness < 200) {
              return "适合中等厚度墙体";
            } else {
              return "适合厚墙体";
            }
          }
      #{'    '}
          function applyToWallType() {
            if (!selectedMaterial) {
              alert('请先选择一个材质');
              return;
            }
      #{'      '}
            if (confirm('确定要将材质应用到所有 "#{wall_type[:name]}" 类型的墙体吗？')) {
              window.location = 'skp:apply_to_wall_type@' + JSON.stringify(selectedMaterial);
            }
          }
      #{'    '}
          function applyToSelected() {
            if (!selectedMaterial) {
              alert('请先选择一个材质');
              return;
            }
            window.location = 'skp:apply_to_selected@' + JSON.stringify(selectedMaterial);
          }
      #{'    '}
          function openMaterialLibrary() {
            window.location = 'skp:open_material_library@';
          }
      #{'    '}
          function saveAsPreset() {
            if (!selectedMaterial) {
              alert('请先选择一个材质');
              return;
            }
            window.location = 'skp:save_as_preset@' + JSON.stringify(selectedMaterial);
          }
        </script>
      </body>
      </html>
    HTML
  end

  # 生成推荐材质卡片HTML
  # @param recommendation [Hash] 推荐材质
  # @param index [Integer] 索引
  # @return [String] HTML片段
  def self.generate_recommendation_card_html(recommendation, index)
    <<~HTML
      <div class="recommendation-card" id="card-#{index}"#{' '}
           onclick="selectMaterial(#{recommendation.to_json.gsub('"', '&quot;')}, #{index})">
        <div class="material-color" style="background-color: #{recommendation[:color]};"></div>
        <div class="material-name">#{recommendation[:name]}</div>
        <div class="material-category">#{recommendation[:category]}</div>
        <div class="recommendation-reason">智能推荐</div>
      </div>
    HTML
  end

  # 设置材质推荐回调
  # @param dialog [UI::WebDialog] 对话框
  # @param wall_type [Hash] 墙体类型
  # @return [void]
  def self.setup_material_recommendation_callbacks(dialog, wall_type)
    dialog.add_action_callback('apply_to_wall_type') do |web_dialog, action_name|
      material_json = action_name.split('@')[1]
      material_config = JSON.parse(material_json, symbolize_names: true)

      apply_material_to_wall_type(wall_type[:name], material_config)
      web_dialog.close
    end

    dialog.add_action_callback('apply_to_selected') do |web_dialog, action_name|
      material_json = action_name.split('@')[1]
      material_config = JSON.parse(material_json, symbolize_names: true)

      manager = material_library_manager
      manager.apply_material_to_selected_walls(material_config)
      web_dialog.close
    end

    dialog.add_action_callback('open_material_library') do |_web_dialog, _action_name|
      show_material_library
    end

    dialog.add_action_callback('save_as_preset') do |_web_dialog, action_name|
      material_json = action_name.split('@')[1]
      material_config = JSON.parse(material_json, symbolize_names: true)

      save_material_as_preset(material_config)
    end
  end

  # 保存材质为预设
  # @param material_config [Hash] 材质配置
  # @return [void]
  def self.save_material_as_preset(material_config)
    RecoveryHelper.with_recovery(operation_name: '保存材质预设') do
      manager = material_library_manager

      # 添加到自定义材质
      custom_materials = manager.custom_materials
      preset_name = UI.inputbox(['预设名称:'], [material_config[:name]], '保存材质预设')[0]

      return unless preset_name && !preset_name.strip.empty?

      custom_materials[preset_name] = material_config
      manager.send(:save_custom_materials)

      UI.messagebox("材质预设 '#{preset_name}' 已保存", MB_OK, '保存成功')
      puts "✅ 材质预设已保存: #{preset_name}"
    end
  end

  # 显示墙体统计
  # @return [void]
  def self.show_wall_statistics
    show_enhanced_wall_statistics
  end

  # 创建所有墙体Tags
  # @return [void]
  def self.create_all_wall_tags
    model = Sketchup.active_model
    types = all_types

    if types.empty?
      UI.messagebox('没有墙体类型可创建Tags')
      return
    end

    created_count = 0
    types.each do |wall_type|
      tag_name = "ZephyrWall_#{wall_type[:name]}"

      # 检查Tag是否已存在
      existing_tag = model.layers.find { |layer| layer.name == tag_name }

      if existing_tag
        puts "ℹ️ Tag已存在: #{tag_name}"
      else
        new_tag = model.layers.add(tag_name)
        new_tag.color = wall_type[:color] if wall_type[:color]
        created_count += 1
        puts "✅ 创建Tag: #{tag_name}"
      end
    end

    UI.messagebox("创建完成！\n新建Tags: #{created_count}个\n总Tags: #{types.length}个", MB_OK, '创建墙体Tags')
  end

  # 从Tags生成墙体
  # @return [void]
  def self.generate_walls_from_tags
    model = Sketchup.active_model
    types = all_types

    if types.empty?
      UI.messagebox('没有墙体类型可生成墙体')
      return
    end

    generated_count = 0

    # 开始操作
    model.start_operation('从Tags生成墙体', true)

    begin
      types.each do |wall_type|
        tag_name = "ZephyrWall_#{wall_type[:name]}"
        tag = model.layers.find { |layer| layer.name == tag_name }

        next unless tag

        # 查找该Tag上的线段
        edges_on_tag = []
        model.active_entities.each do |entity|
          edges_on_tag << entity if entity.is_a?(Sketchup::Edge) && entity.layer == tag
        end

        if edges_on_tag.empty?
          puts "ℹ️ Tag #{tag_name} 上没有线段"
          next
        end

        # 为每条线段生成墙体
        edges_on_tag.each do |edge|
          # 检查线段是否为垂直线段（仅在Z轴方向）
          start_pos = edge.start.position
          end_pos = edge.end.position

          # 计算水平距离
          horizontal_distance = Math.sqrt(((end_pos.x - start_pos.x)**2) + ((end_pos.y - start_pos.y)**2))

          if horizontal_distance < 1.mm.to_f # 如果水平距离小于1mm，认为是垂直线段
            puts "⚠️ 跳过垂直线段: #{start_pos} -> #{end_pos}"
            next
          end

          # 确保 thickness 是 Length 类型，然后计算偏移距离
          thickness = wall_type[:thickness]

          # 强制确保thickness是Length类型
          unless thickness.is_a?(Length)
            puts "⚠️ 厚度不是Length类型，强制转换: #{thickness} (#{thickness.class})"
            thickness = thickness.to_l
          end

          # 计算偏移距离（墙体厚度的一半）- 使用乘法保持 Length 类型
          offset_distance = thickness * 0.5

          # 双重验证：确保偏移距离是Length类型
          unless offset_distance.is_a?(Length)
            puts "⚠️ 偏移距离不是Length类型，强制转换: #{offset_distance} (#{offset_distance.class})"
            # 如果乘法仍然产生非Length类型，使用更安全的方法
            thickness_mm = thickness.is_a?(Length) ? thickness.to_mm : thickness.to_f
            offset_distance = (thickness_mm / 2.0).mm
          end

          puts "🔧 厚度: #{thickness} (#{thickness.class}), 偏移距离: #{offset_distance} (#{offset_distance.class})"

          wall_group = create_wall_segment_from_edge(model.active_entities, edge, wall_type, offset_distance)

          # 确保墙体在正确的图层上
          if wall_group.is_a?(Sketchup::Group)
            wall_group.layer = tag
            puts "🏗️ 从线段生成墙体: #{wall_type[:name]} (长度: #{edge.length.to_mm.round(1)}mm)"
            generated_count += 1
          else
            puts "⚠️ 墙体生成异常: #{wall_type[:name]}"
          end
        rescue StandardError => e
          puts "❌ 生成墙体失败: #{e.message}"
          puts "   线段信息: #{edge.start.position} -> #{edge.end.position}"
          puts "   墙体类型: #{wall_type[:name]}, 厚度: #{wall_type[:thickness]}"
        end
      end

      # 提交操作
      model.commit_operation
    rescue StandardError => e
      # 如果出错，回滚操作
      model.abort_operation
      puts "❌ 批量生成墙体失败: #{e.message}"
      UI.messagebox("生成失败: #{e.message}", MB_OK, '错误')
      return
    end

    UI.messagebox("生成完成！\n共生成 #{generated_count} 个墙体", MB_OK, '从Tags生成墙体')
  end

  # 切换到墙体Tag
  # @param wall_type [Hash] 墙体类型
  # @return [void]
  def self.switch_to_wall_tag(wall_type)
    model = Sketchup.active_model

    # 直接使用墙体类型名称构建图层名称
    layer_name = "ZephyrWall_#{wall_type[:name]}"
    layer = model.layers.find { |l| l.name == layer_name }

    if layer
      success = safe_layer_switch(model, layer)
      if success
        puts "✅ 已切换到墙体类型: #{wall_type[:name]} (图层: #{layer_name})"
      else
        puts "❌ 切换到墙体类型失败: #{wall_type[:name]}"
      end
    else
      puts "⚠️ 未找到对应图层: #{layer_name}，请先创建墙体Tags"
    end
  rescue StandardError => e
    puts "❌ 设置活动图层时出错: #{e.message}"
    puts e.backtrace
    UIRefreshManager.request_refresh(force: true)
  end

  # 切换到默认图层（Layer0）
  def self.switch_to_default_layer
    model = Sketchup.active_model

    # 查找Layer0或第一个图层
    default_layer = model.layers['Layer0'] || model.layers[0]

    if default_layer
      success = safe_layer_switch(model, default_layer)
      if success
        puts "✅ 已切换到默认图层: #{default_layer.name}"
      else
        puts '❌ 切换到默认图层失败'
      end
    else
      puts '❌ 找不到默认图层'
    end
  rescue StandardError => e
    puts "❌ 切换到默认图层时出错: #{e.message}"
    puts e.backtrace
    UIRefreshManager.request_refresh(force: true)
  end

  # 创建编辑墙体类型对话框
  def self.create_edit_type_dialog(type_to_edit, type_index, parent_dialog)
    edit_dialog = UI::WebDialog.new(
      "编辑墙体类型 - #{type_to_edit[:name]}",
      false,
      'ZephyrEditType',
      400,
      500,
      100,
      100,
      true
    )

    # 使用新的辅助方法生成 HTML 和 JavaScript
    full_html = _build_edit_dialog_full_html(type_to_edit)
    edit_dialog.set_html(full_html)

    edit_dialog.add_action_callback('saveChanges') do |_action_context, name, color, thickness_mm, height_mm, tag|
      begin
        # 转换单位
        thickness = thickness_mm.to_f.mm
        height = height_mm.to_f.mm

        updated_type = {
          name: name,
          color: color,
          thickness: thickness,
          height: height,
          tag: tag.empty? ? nil : tag
        }

        # 更新全局类型列表
        @wall_types[type_index] = updated_type
        save_wall_types # 保存到文件

        # 更新主对话框UI
        parent_dialog.execute_script("updateTypeList(#{@wall_types.to_json})")
        parent_dialog.execute_script("selectType(#{type_index})") # 重新选中编辑的类型

        edit_dialog.close
        puts "✅ 墙体类型 '#{name}' 更新成功"
        UIRefreshManager.request_refresh(force: true)
      rescue StandardError => e
        puts "❌ 保存编辑后的墙体类型失败: #{e.message}"
        puts e.backtrace
        edit_dialog.execute_script("alert('保存失败: #{e.message.gsub("'", "\\'")}')")
      end
    end

    edit_dialog.add_action_callback('cancelEdit') do |_action_context|
      edit_dialog.close
    end

    edit_dialog.add_action_callback('openSystemColorPicker') do |action_context|
      # Sketchup.active_model.options['ColorOptions']['ForegroundColor'] # 这是一个示例，实际颜色选择器需要更复杂的逻辑
      # 这里我们模拟一个颜色选择，实际应用中会调用系统颜色选择器
      # chosen_color = UI.select_color(title: "选择颜色", color: Sketchup::Color.new(type_to_edit[:color]))
      # if chosen_color
      #   hex_color = "##{chosen_color.hex}"
      #   action_context.execute_script("setColor('#{hex_color}')")
      # end
      # 由于直接调用系统颜色选择器并返回值给WebDialog比较复杂，这里暂时留空或使用之前的方式
      # 实际项目中，可能需要一个小的Ruby端对话框来辅助，或者通过更复杂的JS-Ruby通信
      # 为了简化，我们假设用户会通过其他方式输入颜色，或者依赖预设颜色
      # 或者，我们可以尝试使用 input type="color"，但这在 SketchUp WebDialog 中可能表现不一致
      puts "🎨 请求打开系统颜色选择器 (当前版本暂未直接集成，请使用预设或手动输入)"
      # 尝试让用户输入
      input_custom_color(action_context, type_to_edit[:color])
    end

    edit_dialog.add_action_callback('inputCustomColor') do |action_context, current_color_hex|
      input_custom_color(action_context, current_color_hex)
    end

    edit_dialog.show
    edit_dialog
  end

  # --- Private Helper Methods for Edit Dialog ---

  # 构建编辑对话框的完整HTML内容
  private_class_method def self._build_edit_dialog_full_html(type_to_edit)
    html_structure = _generate_edit_dialog_html_structure(type_to_edit)
    css_styles = _generate_edit_dialog_css
    javascript_logic = _generate_edit_dialog_js_logic(type_to_edit)

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>编辑墙体类型</title>
        <style>
          #{css_styles}
        </style>
      </head>
      <body>
        #{html_structure}
        <script>
          #{javascript_logic}
        </script>
      </body>
      </html>
    HTML
  end

  # 生成编辑对话框的HTML结构
  private_class_method def self._generate_edit_dialog_html_structure(type_to_edit)
    <<~HTML
      <div class="container">
        <h2>编辑墙体类型</h2>
        <div class="form-group">
          <label>类型名称:</label>
          <input type="text" id="typeName" value="#{type_to_edit[:name]}">
        </div>
        <div class="form-group">
          <label>颜色选择:</label>
          <div class="color-palette">
            <!-- 颜色行将由JS动态生成或保持静态 -->
            <!-- 第一行：基础颜色 -->
            <div class="color-row">
              <div class="color-swatch" style="background-color: #FF6B6B;" onclick="selectColor('#FF6B6B')" title="红色"></div>
              <div class="color-swatch" style="background-color: #FFE66D;" onclick="selectColor('#FFE66D')" title="黄色"></div>
              <div class="color-swatch" style="background-color: #4ECDC4;" onclick="selectColor('#4ECDC4')" title="青色"></div>
              <div class="color-swatch" style="background-color: #45B7D1;" onclick="selectColor('#45B7D1')" title="蓝色"></div>
              <div class="color-swatch" style="background-color: #96CEB4;" onclick="selectColor('#96CEB4')" title="绿色"></div>
              <div class="color-swatch" style="background-color: #FFEAA7;" onclick="selectColor('#FFEAA7')" title="浅黄"></div>
              <div class="color-swatch" style="background-color: #DDA0DD;" onclick="selectColor('#DDA0DD')" title="紫色"></div>
              <div class="color-swatch" style="background-color: #98D8C8;" onclick="selectColor('#98D8C8')" title="薄荷绿"></div>
            </div>
            <!-- 第二行：深色调 -->
            <div class="color-row">
              <div class="color-swatch" style="background-color: #FF3838;" onclick="selectColor('#FF3838')" title="深红"></div>
              <div class="color-swatch" style="background-color: #FFDD59;" onclick="selectColor('#FFDD59')" title="金黄"></div>
              <div class="color-swatch" style="background-color: #26D0CE;" onclick="selectColor('#26D0CE')" title="深青"></div>
              <div class="color-swatch" style="background-color: #3742FA;" onclick="selectColor('#3742FA')" title="深蓝"></div>
              <div class="color-swatch" style="background-color: #2ED573;" onclick="selectColor('#2ED573')" title="深绿"></div>
              <div class="color-swatch" style="background-color: #FFA502;" onclick="selectColor('#FFA502')" title="橙色"></div>
              <div class="color-swatch" style="background-color: #5F27CD;" onclick="selectColor('#5F27CD')" title="深紫"></div>
              <div class="color-swatch" style="background-color: #00D2D3;" onclick="selectColor('#00D2D3')" title="青绿"></div>
            </div>
            <!-- 第三行：建筑常用色 -->
            <div class="color-row">
              <div class="color-swatch" style="background-color: #8B4513;" onclick="selectColor('#8B4513')" title="棕色"></div>
              <div class="color-swatch" style="background-color: #D2691E;" onclick="selectColor('#D2691E')" title="巧克力色"></div>
              <div class="color-swatch" style="background-color: #CD853F;" onclick="selectColor('#CD853F')" title="秘鲁色"></div>
              <div class="color-swatch" style="background-color: #F4A460;" onclick="selectColor('#F4A460')" title="沙棕色"></div>
              <div class="color-swatch" style="background-color: #2F4F4F;" onclick="selectColor('#2F4F4F')" title="深灰绿"></div>
              <div class="color-swatch" style="background-color: #708090;" onclick="selectColor('#708090')" title="石板灰"></div>
              <div class="color-swatch" style="background-color: #778899;" onclick="selectColor('#778899')" title="浅石板灰"></div>
              <div class="color-swatch" style="background-color: #B0C4DE;" onclick="selectColor('#B0C4DE')" title="浅钢蓝"></div>
            </div>
            <!-- 第四行：灰度色 -->
            <div class="color-row">
              <div class="color-swatch" style="background-color: #000000;" onclick="selectColor('#000000')" title="黑色"></div>
              <div class="color-swatch" style="background-color: #404040;" onclick="selectColor('#404040')" title="深灰"></div>
              <div class="color-swatch" style="background-color: #808080;" onclick="selectColor('#808080')" title="灰色"></div>
              <div class="color-swatch" style="background-color: #C0C0C0;" onclick="selectColor('#C0C0C0')" title="银色"></div>
              <div class="color-swatch" style="background-color: #E0E0E0;" onclick="selectColor('#E0E0E0')" title="浅灰"></div>
              <div class="color-swatch" style="background-color: #F5F5F5;" onclick="selectColor('#F5F5F5')" title="烟白"></div>
              <div class="color-swatch" style="background-color: #FFFFFF;" onclick="selectColor('#FFFFFF')" title="白色"></div>
              <div class="color-swatch custom-color" onclick="openSystemColorPicker()" title="自定义颜色">
                <span style="font-size: 12px;">🎨</span>
              </div>
            </div>
          </div>
          <input type="hidden" id="typeColor" value="#{type_to_edit[:color]}">
          <div id="colorPreview" class="color-preview" style="background-color: #{type_to_edit[:color]};"></div>
        </div>
        <div class="form-group">
          <label>厚度 (mm):</label>
          <input type="number" id="typeThickness" value="#{type_to_edit[:thickness].to_mm.round(1)}">
        </div>
        <div class="form-group">
          <label>高度 (mm):</label>
          <input type="number" id="typeHeight" value="#{type_to_edit[:height].to_mm.round(1)}">
        </div>
        <div class="form-group">
          <label>标签:</label>
          <input type="text" id="typeTag" value="#{type_to_edit[:tag] || ''}">
        </div>
        <div class="button-group">
          <button class="save-btn" onclick="saveChanges()">保存</button>
          <button class="cancel-btn" onclick="cancelEdit()">取消</button>
        </div>
      </div>
    HTML
  end

  # 生成编辑对话框的CSS样式
  private_class_method def self._generate_edit_dialog_css
    <<~CSS
      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        margin: 0;
        padding: 20px;
        background: #f5f5f5;
      }
      .container {
        background: white;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      }
      h2 {
        margin-top: 0;
        color: #333;
        border-bottom: 2px solid #4a90e2;
        padding-bottom: 10px;
      }
      .form-group {
        margin-bottom: 15px;
      }
      label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
        color: #555;
      }
      input[type="text"], input[type="number"] {
        width: 100%;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
        box-sizing: border-box;
      }
      input[type="text"]:focus, input[type="number"]:focus {
        outline: none;
        border-color: #4a90e2;
        box-shadow: 0 0 5px rgba(74, 144, 226, 0.3);
      }
      .color-palette {
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 8px;
        background: #fafafa;
        margin-bottom: 8px;
      }
      .color-row {
        display: flex;
        gap: 4px;
        margin-bottom: 4px;
      }
      .color-row:last-child {
        margin-bottom: 0;
      }
      .color-swatch {
        width: 24px;
        height: 24px;
        border: 2px solid #fff;
        border-radius: 3px;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        display: flex;
        align-items: center;
        justify-content: center;
      }
      .color-swatch:hover {
        transform: scale(1.1);
        box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        border-color: #4a90e2;
      }
      .color-swatch.selected {
        border-color: #4a90e2;
        border-width: 3px;
        transform: scale(1.05);
      }
      .custom-color {
        background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);
        color: white;
        font-weight: bold;
        text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
      }
      .color-preview {
        width: 100%;
        height: 30px;
        border: 1px solid #ccc;
        border-radius: 4px;
        margin-top: 8px;
      }
      .button-group {
        display: flex;
        gap: 10px;
        margin-top: 20px;
      }
      button {
        flex: 1;
        padding: 10px;
        border: none;
        border-radius: 4px;
        font-size: 14px;
        cursor: pointer;
        transition: background-color 0.2s;
      }
      .save-btn {
        background: linear-gradient(to bottom, #28a745, #1e7e34);
        color: white;
      }
      .save-btn:hover {
        background: linear-gradient(to bottom, #218838, #1c7430);
      }
      .cancel-btn {
        background: linear-gradient(to bottom, #6c757d, #545b62);
        color: white;
      }
      .cancel-btn:hover {
        background: linear-gradient(to bottom, #5a6268, #4e555b);
      }
    CSS
  end

  # 生成编辑对话框的JavaScript逻辑
  private_class_method def self._generate_edit_dialog_js_logic(type_to_edit)
    <<~JS
      // 初始化时标记当前颜色
      window.onload = function() {
        const currentColor = '#{type_to_edit[:color]}';
        markSelectedColor(currentColor);
      };

      function markSelectedColor(color) {
        document.querySelectorAll('.color-swatch').forEach(swatch => {
          swatch.classList.remove('selected');
          // 注意：直接比较 style.backgroundColor 和 color 可能因格式不同而出错 (e.g. rgb vs hex)
          // 更可靠的方式是给 swatch 添加 data-color 属性并在选择时比较
          // 这里为了简化，假设颜色格式一致或通过其他方式处理
          if (swatch.style.backgroundColor === color || rgbToHex(swatch.style.backgroundColor) === color.toLowerCase()) {
            swatch.classList.add('selected');
          }
        });
      }

      // 辅助函数：将 RGB 颜色转换为 HEX (如果需要)
      function rgbToHex(rgb) {
        if (!rgb || !rgb.startsWith('rgb')) return rgb; // 如果不是rgb格式，直接返回
        let sep = rgb.indexOf(",") > -1 ? "," : " ";
        rgb = rgb.substr(4).split(")")[0].split(sep);

        let r = (+rgb[0]).toString(16),
            g = (+rgb[1]).toString(16),
            b = (+rgb[2]).toString(16);

        if (r.length == 1) r = "0" + r;
        if (g.length == 1) g = "0" + g;
        if (b.length == 1) b = "0" + b;

        return "#" + r + g + b;
      }

      function selectColor(color) {
        document.getElementById('typeColor').value = color;
        document.getElementById('colorPreview').style.backgroundColor = color;
        markSelectedColor(color);
      }

      function saveChanges() {
        const name = document.getElementById('typeName').value;
        const color = document.getElementById('typeColor').value;
        const thickness = document.getElementById('typeThickness').value;
        const height = document.getElementById('typeHeight').value;
        const tag = document.getElementById('typeTag').value;

        if (!name || name.trim() === '') {
          alert('类型名称不能为空。');
          return;
        }
        if (!thickness || parseFloat(thickness) <= 0) {
          alert('厚度必须是正数。');
          return;
        }
        if (!height || parseFloat(height) <= 0) {
          alert('高度必须是正数。');
          return;
        }

        sketchup.saveChanges(name, color, thickness, height, tag);
      }

      function cancelEdit() {
        sketchup.cancelEdit();
      }

      function openSystemColorPicker() {
        sketchup.openSystemColorPicker();
      }

      // 由Ruby端调用，设置颜色
      function setColor(hexColor) {
        selectColor(hexColor);
      }

      // 当用户点击自定义颜色按钮后，如果Ruby端调用inputCustomColor，
      // 并且用户输入了颜色，这个函数会被Ruby调用以更新UI
      function updateCustomColor(hexColor) {
        if (hexColor) {
          selectColor(hexColor);
        }
      }
    JS
  end

  # 生成编辑对话框的HTML内容
  private_class_method def self._generate_edit_dialog_html(type_to_edit)
    css_content = _generate_edit_dialog_css
    js_content = _generate_edit_dialog_js_logic(type_to_edit)
    
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>编辑墙体类型</title>
        <style>
          #{css_content}
        </style>
      </head>
      <body>
        <div class="container">
          <h2>编辑墙体类型</h2>
          
          <div class="form-group">
            <label for="typeName">类型名称:</label>
            <input type="text" id="typeName" value="#{type_to_edit[:name]}">
          </div>
          
          <div class="form-group">
            <label for="typeColor">颜色:</label>
            <div class="color-input-group">
              <input type="color" id="typeColor" value="#{type_to_edit[:color]}">
              <div id="colorPreview" class="color-preview" style="background-color: #{type_to_edit[:color]}"></div>
              <button type="button" class="system-color-btn" onclick="openSystemColorPicker()">系统颜色</button>
            </div>
            
            <div class="color-swatches">
              #{_generate_color_swatches}
            </div>
          </div>
          
          <div class="form-group">
            <label for="typeThickness">厚度 (mm):</label>
            <input type="number" id="typeThickness" value="#{type_to_edit[:thickness].to_mm.round(2)}" step="0.1" min="0.1">
          </div>
          
          <div class="form-group">
            <label for="typeHeight">高度 (mm):</label>
            <input type="number" id="typeHeight" value="#{type_to_edit[:height].to_mm.round(2)}" step="1" min="1">
          </div>
          
          <div class="form-group">
            <label for="typeTag">标签:</label>
            <input type="text" id="typeTag" value="#{type_to_edit[:tag]}">
          </div>
          
          <div class="button-group">
            <button type="button" class="save-btn" onclick="saveChanges()">保存</button>
            <button type="button" class="cancel-btn" onclick="cancelEdit()">取消</button>
          </div>
        </div>
        
        <script>
          #{js_content}
        </script>
      </body>
      </html>
    HTML

    edit_dialog.set_html(html_content)

    # 添加回调处理
    edit_dialog.add_action_callback('saveEditedType') do |_action_context, params|
      name, color, thickness, height, tag = params.split(',').map { |v| CGI.unescape(v) }

      types = all_types
      types[type_index][:name] = name
      types[type_index][:color] = color
      types[type_index][:thickness] = thickness.to_f.mm
      types[type_index][:height] = height.to_f.mm
      types[type_index][:tag] = tag

      save_types(types)

      # 更新主界面
      parent_dialog.execute_script("updateTypeList(#{types_for_js(types).to_json})")

      # 关闭编辑对话框
      edit_dialog.close
      @@edit_dialog = nil # 清理引用

      puts "已编辑墙体类型: #{name}"
      UI.messagebox('墙体类型已更新！')
    rescue StandardError => e
      puts "保存编辑时出错: #{e.message}"
      UI.messagebox("保存失败: #{e.message}")
    end

    edit_dialog.add_action_callback('cancelEdit') do |_action_context|
      edit_dialog.close
      @@edit_dialog = nil # 清理引用
    end

    edit_dialog.add_action_callback('openSystemColorPicker') do |_action_context|
      color = open_system_color_picker_macos
      if color
        hex_color = if color.is_a?(Sketchup::Color)
                      format('#%02X%02X%02X', color.red, color.green, color.blue)
                    else
                      color.to_s
                    end
        edit_dialog.execute_script("setColor('#{hex_color}')")
      end
    end

    # 存储编辑对话框引用，方便重载时清理
    @@edit_dialog = edit_dialog

    edit_dialog.show
  end

  # 简单安全的颜色选择器 - 避免假死问题
  def self.open_safe_color_picker
    puts '🎨 启动安全颜色选择器...'

    # 预设颜色选项
    color_options = [
      { name: '红色', value: '#FF0000' },
      { name: '绿色', value: '#00FF00' },
      { name: '蓝色', value: '#0000FF' },
      { name: '黄色', value: '#FFFF00' },
      { name: '紫色', value: '#FF00FF' },
      { name: '青色', value: '#00FFFF' },
      { name: '橙色', value: '#FFA500' },
      { name: '粉色', value: '#FFC0CB' },
      { name: '棕色', value: '#A52A2A' },
      { name: '灰色', value: '#808080' },
      { name: '黑色', value: '#000000' },
      { name: '白色', value: '#FFFFFF' },
      { name: '自定义...', value: 'custom' }
    ]

    # 创建选择列表
    color_names = color_options.map { |c| c[:name] }

    result = UI.inputbox(
      ['选择颜色:'],
      [color_names.first],
      color_names,
      '颜色选择器'
    )

    if result && !result[0].empty?
      selected_name = result[0]
      selected_option = color_options.find { |c| c[:name] == selected_name }

      if selected_option
        if selected_option[:value] == 'custom'
          # 用户选择自定义颜色
          custom_result = UI.inputbox(
            ['输入十六进制颜色值 (如: #FF0000):'],
            ['#FF0000'],
            '自定义颜色'
          )

          if custom_result && !custom_result[0].empty?
            color_input = custom_result[0].strip
            if color_input.match(/^#[0-9A-Fa-f]{6}$/)
              r = color_input[1..2].to_i(16)
              g = color_input[3..4].to_i(16)
              b = color_input[5..6].to_i(16)
              puts "✅ 自定义颜色: RGB(#{r}, #{g}, #{b})"
              return Sketchup::Color.new(r, g, b)
            else
              puts "❌ 无效的颜色格式: #{color_input}"
              return nil
            end
          end
        else
          # 预设颜色
          hex_color = selected_option[:value]
          r = hex_color[1..2].to_i(16)
          g = hex_color[3..4].to_i(16)
          b = hex_color[5..6].to_i(16)
          puts "✅ 选择预设颜色: #{selected_name} RGB(#{r}, #{g}, #{b})"
          return Sketchup::Color.new(r, g, b)
        end
      end
    end

    puts '❌ 用户取消了颜色选择'
    nil
  rescue StandardError => e
    puts "❌ 安全颜色选择器错误: #{e.message}"
    nil
  end
end
=======
    # 如果对话框已存在，直接显示
    if defined?(@@current_dialog) && @@current_dialog
      begin
        @@current_dialog.bring_to_front
        @@current_dialog.show
        return
      rescue => e
        puts "Error bringing dialog to front: #{e.message}"
        # 如果出错，创建新的对话框
        @@current_dialog = nil
      end
    end
    
    # 创建新的对话框
    self.create_toolbox_dialog
  end

  # 为JavaScript准备数据（转换Length为毫米数值）
  def self.types_for_js(runtime_types)
    runtime_types.map do |type|
      {
        name: type[:name],
        color: type[:color],
        thickness: type[:thickness].to_mm.to_f,  # 明确转换为毫米数值
        height: type[:height].to_mm.to_f,        # 明确转换为毫米数值
        tag: type[:tag]
      }
    end
  end

  # 清理旧的存储数据，强制使用新系统
  def self.clear_old_data
    model = Sketchup.active_model
    puts "Clearing old data format..."
    
    # 删除旧的数组格式存储
    model.delete_attribute(TYPE_DICT, 'types')
    
    # 强制重置计数器
    model.set_attribute(TYPE_DICT, 'count', 0)
    
    puts "Old data cleared, will recreate using new format"
  end

  # 获取SketchUp语言设置
  def self.get_sketchup_language
    # SketchUp的语言代码
    begin
      locale = Sketchup.get_locale
      puts "SketchUp locale: #{locale}"
      locale
    rescue
      "en" # 默认英语
    end
  end

  # 本地化文本
  def self.localize_text(key)
    locale = self.get_sketchup_language
    
    texts = {
      "zh" => {
        title: "墙体类型工具箱",
        add_type: "新建类型",
        delete_type: "删除选中",
        type_name: "类型名称",
        thickness: "厚度 (mm)",
        height: "高度 (mm)", 
        tag: "标签",
        color: "颜色",
        save: "保存",
        cancel: "取消",
        select_material: "选择材质",
        custom_color: "自定义颜色"
      },
      "en" => {
        title: "Wall Type Toolbox",
        add_type: "Add Type",
        delete_type: "Delete Selected",
        type_name: "Type Name",
        thickness: "Thickness (mm)",
        height: "Height (mm)",
        tag: "Tag", 
        color: "Color",
        save: "Save",
        cancel: "Cancel",
        select_material: "Select Material",
        custom_color: "Custom Color"
      }
    }
    
    lang = texts[locale] || texts["en"]
    lang[key] || key.to_s
  end

  # 原生风格的类型添加对话框
  def self.native_add_type_dialog
    texts = {
      type_name: self.localize_text(:type_name),
      thickness: self.localize_text(:thickness),
      height: self.localize_text(:height),
      tag: self.localize_text(:tag),
      title: self.localize_text(:add_type)
    }
    
    # 使用SketchUp原生inputbox，样式更接近Entity Info
    prompts = [
      texts[:type_name],
      texts[:thickness], 
      texts[:height],
      texts[:tag]
    ]
    
    defaults = ["新墙体类型", "200", "2800", "标准"]
    
    results = UI.inputbox(prompts, defaults, texts[:title])
    
    if results
      name, thickness, height, tag = results
      
      # 颜色选择使用单独的对话框
      color = self.native_color_picker
      
      if color
        new_type = {
          name: name,
          color: color,
          thickness: thickness.to_f.mm,
          height: height.to_f.mm,
          tag: tag
        }
        
        # 添加到现有类型
        types = self.all_types
        types << new_type
        self.save_types(types)
        
        # 刷新当前对话框
        if defined?(@@current_dialog) && @@current_dialog
          updated_types = self.all_types
          @@current_dialog.execute_script("updateTypeList(#{self.types_for_js(updated_types).to_json})")
        end
        
        UI.messagebox("类型 '#{name}' 添加成功！")
        return true
      end
    end
    
    false
  end

  # 原生风格的颜色选择器
  def self.native_color_picker
    model = Sketchup.active_model
    
    # 方法1: 尝试获取当前材质
    current_material = model.materials.current
    if current_material && current_material.color
      choice = UI.messagebox(
        "使用当前选中的材质 '#{current_material.display_name}' 吗？", 
        MB_YESNOCANCEL
      )
      
      case choice
      when IDYES
        return sprintf("#%02X%02X%02X", 
          current_material.color.red, 
          current_material.color.green, 
          current_material.color.blue)
      when IDCANCEL
        return nil
      end
    end
    
    # 方法2: 从模型中的材质选择
    materials = model.materials.to_a
    if materials.length > 0
      material_names = materials.map.with_index { |mat, i| "#{i+1}. #{mat.display_name}" }
      choice = UI.inputbox(
        ["选择材质 (输入序号):"],
        ["1"],
        "模型材质:\n#{material_names.join("\n")}"
      )
      
      if choice && choice[0].to_i > 0 && choice[0].to_i <= materials.length
        selected_material = materials[choice[0].to_i - 1]
        return sprintf("#%02X%02X%02X", 
          selected_material.color.red, 
          selected_material.color.green, 
          selected_material.color.blue)
      end
    end
    
    # 方法3: 手动输入颜色
    color_choice = UI.inputbox(
      ["颜色 (名称或#RRGGBB):"],
      ["#808080"],
      "颜色选择"
    )
    
    if color_choice && !color_choice[0].empty?
      return color_choice[0]
    end
    
    nil
  end

  # 移除了这里的 unless file_loaded?(__FILE__) 块，因为它包含了重复的菜单和工具栏注册代码
  # UI注册现在统一由 zephyr_wall_tool_loader.rb 处理
end
>>>>>>> cb71b8266932ee65ed89189d06c7a1fc7b58dbec
