# Zephyr Wall Tool - SketchUp 墙体类型管理插件

[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)](https://github.com/Zedesignn/ZephyrBuildsTakeOff/releases/tag/v1.0.0)
[![SketchUp](https://img.shields.io/badge/SketchUp-2024-blue.svg)](https://www.sketchup.com/)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)

## 🎉 版本 1.0.0 - 稳定可用版本

这是一个功能完整、经过充分测试的SketchUp墙体类型管理工具。

## ✨ 主要功能

### 🏗️ 墙体类型管理
- **完整的类型系统**：添加、删除、编辑墙体类型
- **数据持久化**：重启SketchUp后数据保持不变
- **自动单位处理**：智能转换毫米和SketchUp Length对象

### 🎨 双模式界面
- **原生对话框模式**：完全遵循SketchUp UI规范
- **现代Web界面**：功能丰富的工具箱面板
- **自动语言切换**：根据SketchUp语言设置自动调整界面

### 🔧 技术特性
- **分离式存储架构**：解决SketchUp Attribute Dictionary兼容性问题
- **自动数据迁移**：从旧版本无缝升级
- **材质系统集成**：直接使用SketchUp材质库
- **macOS优化**：专门针对macOS SketchUp 2024优化

## 📦 安装方法

1. 下载 [`zephyr_wall_tool_v1.0.0.rbz`](./zephyr_wall_tool_v1.0.0.rbz)
2. 在SketchUp中：**扩展程序** → **扩展程序管理器** → **安装扩展程序**
3. 选择下载的.rbz文件
4. 重启SketchUp
5. 在菜单栏 **扩展程序** → **Zephyr Wall Tool** → **管理墙体类型**

## 🚀 使用方法

### 原生模式
1. 点击 **"使用原生对话框添加"**
2. 在SketchUp原生输入框中填写信息
3. 选择材质颜色
4. 保存即可

### Web界面模式  
1. 点击 **"网页版添加"**
2. 填写类型信息
3. 选择预设颜色或自定义颜色
4. 保存并查看实时更新

## 🛠️ 开发信息

- **开发语言**：Ruby + HTML/CSS/JavaScript
- **SketchUp API**：2024版本
- **目标平台**：macOS SketchUp 2024
- **数据存储**：SketchUp Attribute Dictionary（分离式架构）

## 📋 更新日志

### v1.0.0 (2025-05-23)
✅ **稳定发布版本**
- 完整实现墙体类型管理系统
- 数据持久化完全稳定
- 双模式UI界面
- 自动语言本地化
- SketchUp原生UI集成
- 材质系统深度集成

## 🔮 未来计划

- [ ] CSV数据导出功能
- [ ] 自动编号系统
- [ ] 墙体绘制工具
- [ ] 批量操作功能
- [ ] 更多平台支持

## 📞 支持

如有问题或建议，请在 [GitHub Issues](https://github.com/Zedesignn/ZephyrBuildsTakeOff/issues) 中提出。

---
**开发者**: Zedesignn  
**许可证**: MIT License