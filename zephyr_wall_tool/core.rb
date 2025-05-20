require 'sketchup.rb'

module ZephyrWallTool
  # 墙体类型定义
  WALL_TYPES = {
    'GYP90' => { thickness: 0.090, name: 'GYP90' },
    'FC75' => { thickness: 0.075, name: 'FC75' },
    'WR64' => { thickness: 0.064, name: 'WR64' }
  }

  # 默认设置
  DEFAULT_HEIGHT = 2.4

  # 当前选择的墙体类型
  @current_wall_type = 'GYP90'

  # 创建墙体
  def self.create_wall(start_point, end_point)
    model = Sketchup.active_model
    model.start_operation('Create Wall', true)

    # 获取当前墙体类型的厚度
    thickness = WALL_TYPES[@current_wall_type][:thickness]
    # 计算墙体长度
    length = start_point.distance(end_point)
    # 创建墙体组
    group = model.active_entities.add_group
    # 创建墙体面
    points = [
      [0, 0, 0],
      [length, 0, 0],
      [length, thickness, 0],
      [0, thickness, 0]
    ]
    # 创建底面
    face = group.entities.add_face(points)
    # 拉伸墙体
    face.pushpull(DEFAULT_HEIGHT)
    # 设置墙体属性
    group.set_attribute('ZephyrWall', 'type', @current_wall_type)
    group.set_attribute('ZephyrWall', 'length', length)
    group.set_attribute('ZephyrWall', 'height', DEFAULT_HEIGHT)
    group.set_attribute('ZephyrWall', 'thickness', thickness)
    # 移动墙体到正确位置
    transformation = Geom::Transformation.new(start_point, [1, 0, 0], [0, 0, 1])
    group.transform!(transformation)
    model.commit_operation
  end

  # 墙体类型选择对话框
  def self.show_wall_type_dialog
    prompts = ['选择墙体类型']
    defaults = [@current_wall_type]
    lists = [WALL_TYPES.keys.join('|')]
    results = UI.inputbox(prompts, defaults, lists, '墙体类型选择')
    if results
      @current_wall_type = results[0]
    end
  end

  # 创建墙体工具类
  class WallTool
    def initialize
      @start_point = nil
      @end_point = nil
    end

    def activate
      ZephyrWallTool.show_wall_type_dialog
    end

    def deactivate(view)
      view.invalidate
    end

    def onMouseMove(flags, x, y, view)
      if @start_point
        @end_point = view.inputpoint(x, y).position
        view.invalidate
      end
    end

    def onLButtonDown(flags, x, y, view)
      if @start_point.nil?
        @start_point = view.inputpoint(x, y).position
      else
        @end_point = view.inputpoint(x, y).position
        ZephyrWallTool.create_wall(@start_point, @end_point)
        @start_point = nil
        @end_point = nil
      end
      view.invalidate
    end

    def draw(view)
      if @start_point && @end_point
        view.set_color_from_line(@start_point, @end_point)
        view.draw_line(@start_point, @end_point)
      end
    end
  end
end 