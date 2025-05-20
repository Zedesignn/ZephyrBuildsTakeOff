require 'sketchup.rb'
require File.join(File.dirname(__FILE__), 'zephyr_wall_tool', 'core.rb')

unless file_loaded?(__FILE__)
  menu = UI.menu('Extensions') # 现在入口会出现在 Extensions 菜单下
  menu.add_item('墙体类型管理') {
    ZephyrWallTool.manage_types
  }
  file_loaded(__FILE__)
end 