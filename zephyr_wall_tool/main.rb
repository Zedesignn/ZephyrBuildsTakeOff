require 'sketchup.rb'

# 获取当前文件所在目录
current_dir = File.dirname(__FILE__)

# 加载所有必要的文件
require File.join(current_dir, 'zephyr_wall_tool.rb')
require File.join(current_dir, 'zephyr_wall_tool_toolbar.rb')

# 创建菜单
unless file_loaded?(__FILE__)
  # 创建主菜单
  menu = UI.menu('Plugins')
  menu.add_item('Zephyr Wall Tool') {
    Sketchup.active_model.select_tool(ZephyrWallTool::WallTool.new)
  }
  
  # 创建工具栏
  toolbar = UI::Toolbar.new("Zephyr Wall Tool")
  
  # 创建命令
  cmd = UI::Command.new("创建墙体") {
    Sketchup.active_model.select_tool(ZephyrWallTool::WallTool.new)
  }
  
  # 设置命令属性
  cmd.small_icon = File.join(current_dir, "images", "wall_16.png")
  cmd.large_icon = File.join(current_dir, "images", "wall_16.png") # 暂时使用同一个图标
  cmd.tooltip = "创建墙体"
  cmd.status_bar_text = "点击两点创建墙体"
  
  # 添加命令到工具栏
  toolbar.add_item(cmd)
  
  # 显示工具栏
  toolbar.show
  
  file_loaded(__FILE__)
end 