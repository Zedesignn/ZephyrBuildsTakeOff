require 'sketchup.rb'

# 获取当前文件所在目录
current_dir = File.dirname(__FILE__)

# 加载主插件文件
require File.join(current_dir, 'zephyr_wall_tool.rb') 