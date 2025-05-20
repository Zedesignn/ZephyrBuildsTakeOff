require 'sketchup.rb'

module ZephyrWallTool
  TYPE_DICT = 'WallTypes'

  # 获取所有类型
  def self.all_types
    model = Sketchup.active_model
    types = model.get_attribute(TYPE_DICT, 'types')
    types.is_a?(Array) ? types : []
  end

  # 保存所有类型
  def self.save_types(types)
    Sketchup.active_model.set_attribute(TYPE_DICT, 'types', types)
  end

  # 类型管理主入口
  def self.manage_types
    types = all_types
    loop do
      names = types.map { |t| t['name'] }
      choice = UI.inputbox([
        '输入新类型名称，或选择已有类型进行编辑/删除：\n' + names.join("\n")
      ], [''], [''], '墙体类型管理')
      break unless choice
      name = choice[0].strip
      if name.empty?
        break
      elsif names.include?(name)
        idx = names.index(name)
        type = types[idx]
        action = UI.messagebox("编辑类型: #{name}\n厚度: #{type['thickness']}\n高度: #{type['height']}\n颜色: #{type['color']}\n标签: #{type['tag']}\n\n选择"是"编辑，"否"删除，"取消"返回。", MB_YESNOCANCEL)
        if action == IDYES
          # 编辑
          vals = UI.inputbox(['名称', '厚度(m)', '高度(m)', '颜色', '标签'],
            [type['name'], type['thickness'], type['height'], type['color'], type['tag']],
            ['', '', '', '', ''],
            '编辑类型')
          if vals
            types[idx] = {
              'name' => vals[0],
              'thickness' => vals[1].to_f,
              'height' => vals[2].to_f,
              'color' => vals[3],
              'tag' => vals[4]
            }
            save_types(types)
            UI.messagebox('类型已更新！')
          end
        elsif action == IDNO
          # 删除
          types.delete_at(idx)
          save_types(types)
          UI.messagebox('类型已删除！')
        end
      else
        # 新增
        vals = UI.inputbox(['厚度(m)', '高度(m)', '颜色', '标签'], [0.09, 2.4, '', ''], ['', '', '', ''], '新建类型')
        if vals
          types << {
            'name' => name,
            'thickness' => vals[0].to_f,
            'height' => vals[1].to_f,
            'color' => vals[2],
            'tag' => vals[3]
          }
          save_types(types)
          UI.messagebox('类型已添加！')
        end
      end
    end
  end
end 