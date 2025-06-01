#!/bin/bash
# 自动打包 SketchUp 插件并带版本号命名

PLUGIN_NAME="zephyr_wall_tool"
LOADER_FILE="zephyr_wall_tool_loader.rb"
CORE_DIR="zephyr_wall_tool"

# 读取版本号（可从 core.rb 或自定义 version.txt 读取，这里假设 version.txt）
VERSION=""
if [ -f version.txt ]; then
  VERSION=$(cat version.txt | tr -d '\n')
else
  VERSION="dev"
fi

PKG_NAME="${PLUGIN_NAME}_v${VERSION}.rbz"

# 打包
zip -r "$PKG_NAME" "$LOADER_FILE" "$CORE_DIR" > /dev/null

echo "插件已打包为: $PKG_NAME" 