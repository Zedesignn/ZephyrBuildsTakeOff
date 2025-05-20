require 'sketchup.rb'

module ZephyrWallTool
  TYPE_DICT = 'WallTypes'
  DEFAULT_TYPES = [
    { name: "默认墙体", color: "Red", thickness: 200.mm, height: 2800.mm, tag: "标准墙" }
  ]

  # 获取所有类型
  def self.all_types
    model = Sketchup.active_model
    types = model.get_attribute(TYPE_DICT, 'types')
    # 如果模型中没有类型数据，则使用默认类型初始化
    if types.nil? || !types.is_a?(Array) || types.empty?
      types = DEFAULT_TYPES
      self.save_types(types) # 保存默认类型到模型
    end
    types
  end

  # 保存所有类型
  def self.save_types(types)
    Sketchup.active_model.set_attribute(TYPE_DICT, 'types', types)
  end

  # 类型管理主入口
  def self.manage_types
    types = self.all_types

    # 构建类型列表字符串用于显示
    type_list_str = types.empty? ? "当前没有已定义的墙体类型。\n" : "现有墙体类型：\n"
    types.each_with_index do |type, index|
      type_list_str += "#{index + 1}. 名称: #{type[:name]}, 颜色: #{type[:color]}, 厚度: #{type[:thickness]}, 高度: #{type[:height]}, 标签: #{type[:tag]}\n"
    end

    prompts = ["操作：", "类型名称:", "颜色 (例如 Red, Blue, [R,G,B]):", "厚度 (例如 200.mm):", "高度 (例如 2800.mm):", "标签:"]
    defaults = ["查看/添加/编辑/删除", "新墙体类型", "Gray", "200.mm", "3000.mm", "自定义墙"]
    
    # 简化交互，先提供添加和查看功能
    # 后续可以使用 UI::HtmlDialog 实现更复杂的界面
    options_list = "添加|查看|取消"
    user_choice_prompt = UI.inputbox(["请选择操作："], [""], [options_list], "墙体类型管理")
    return unless user_choice_prompt
    
    action = user_choice_prompt[0]

    case action
    when "添加"
      input_prompts = ["类型名称:", "颜色 (例如 Red, Blue, [R,G,B]):", "厚度 (例如 200.mm):", "高度 (例如 2800.mm):", "标签:"]
      input_defaults = ["新墙体类型", "Gray", "200.mm", "3000.mm", "自定义墙"]
      
      details = UI.inputbox(input_prompts, input_defaults, "添加新墙体类型")
      return unless details # 用户取消

      new_type = {
        name: details[0],
        color: details[1],
        thickness: Sketchup.parse_length(details[2]) || 200.mm, 
        height: Sketchup.parse_length(details[3]) || 3000.mm,  
        tag: details[4]
      }
      types << new_type
      self.save_types(types)
      UI.messagebox("新类型 '#{new_type[:name]}' 已添加！\n#{type_list_str}#{types.size}. 名称: #{new_type[:name]}, ...")
    
    when "查看"
      current_types_display = types.empty? ? "当前没有已定义的墙体类型。\n" : "现有墙体类型：\n"
      types.each_with_index do |type, index|
        current_types_display += "#{index + 1}. 名称: #{type[:name]}, 颜色: #{type[:color]}, 厚度: #{type[:thickness].to_s}, 高度: #{type[:height].to_s}, 标签: #{type[:tag]}\n"
      end
      UI.messagebox(current_types_display)
    else
      return
    end
  end

  # 移除了这里的 unless file_loaded?(__FILE__) 块，因为它包含了重复的菜单和工具栏注册代码
  # UI注册现在统一由 zephyr_wall_tool_loader.rb 处理
end