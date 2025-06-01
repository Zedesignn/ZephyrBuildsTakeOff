require File.join(File.dirname(__FILE__), 'zephyr_wall_tool', 'core.rb')

unless file_loaded?(__FILE__)
  menu = UI.menu('Extensions')
  menu.add_item('Zephyr Wall Tool') {
    ZephyrWallTool.manage_types
  }

  toolbar = UI::Toolbar.new("Zephyr Wall Tool")
  cmd = UI::Command.new("墙体类型管理") {
    ZephyrWallTool.manage_types
  }
  icon_path = File.join(File.dirname(__FILE__), "zephyr_wall_tool", "images", "wall_16.png")
  cmd.small_icon = icon_path
  cmd.large_icon = icon_path
  cmd.tooltip = "墙体类型管理"
  cmd.status_bar_text = "打开墙体类型管理面板"
  toolbar.add_item(cmd)
  toolbar.show

  file_loaded(__FILE__)
end 