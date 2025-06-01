# 测试脚本使用说明

这个文件夹包含了各种用于测试和调试Zephyr Wall Tool插件的Ruby脚本。

> 📖 **完整使用指南**: 请查看 `../Zephyr_Wall_Tool_完整指南.md` 获取详细的使用说明和故障排除方法。

## 📁 核心测试脚本

| 脚本名称 | 功能描述 | 推荐使用场景 |
|----------|----------|-------------|
| **`simple_reload.rb`** | 简化重载脚本（兼容所有版本） | 旧版SketchUp，基础重载 |
| **`safe_reload.rb`** | 安全重载脚本（推荐） | SketchUp 2019+，日常开发 |
| `test_reload.rb` | 标准重载和验证 | 基础功能测试 |
| `force_reload.rb` | 强制重载脚本 | 深度调试，开发用 |
| `length_fix_test.rb` | Length类型修复测试 | Length问题诊断 |
| `wall_generation_test.rb` | 墙体生成测试 | 完整流程测试 |
| `toolbar_manager.rb` | 工具栏管理器 | 工具栏问题解决（需2019+） |
| `toolbar_cleanup.rb` | 基础工具栏清理 | 简单工具栏清理（需2019+） |
| `ui_test.rb` | UI测试 | 界面功能测试 |
| `debug_length_issue.rb` | Length问题调试 | 深度Length分析 |
| `quick_reload.rb` | 快速重载 | 简化重载 |

## 🚀 快速开始

### 推荐使用流程
```ruby
# 1. 简化重载（兼容所有SketchUp版本）
load '/Users/Z/Downloads/Zephyr Builds Take Off/tests/simple_reload.rb'

# 2. 安全重载（SketchUp 2019+，推荐）
load '/Users/Z/Downloads/Zephyr Builds Take Off/tests/safe_reload.rb'

# 3. 如果有工具栏问题（仅SketchUp 2019+）
load '/Users/Z/Downloads/Zephyr Builds Take Off/tests/toolbar_manager.rb'
ZephyrToolbarManager.reset_toolbar_completely

# 4. 如果有Length问题
load '/Users/Z/Downloads/Zephyr Builds Take Off/tests/length_fix_test.rb'
```

## 🔧 常见问题快速解决

| 问题类型 | 推荐脚本 | 命令 |
|----------|----------|------|
| 插件重载（所有版本） | `simple_reload.rb` | `load '...simple_reload.rb'` |
| 插件重载（2019+） | `safe_reload.rb` | `load '...safe_reload.rb'` |
| 工具栏重复（2019+） | `toolbar_manager.rb` | `ZephyrToolbarManager.reset_toolbar_completely` |
| Length错误 | `length_fix_test.rb` | `load '...length_fix_test.rb'` |
| 墙体生成失败 | `wall_generation_test.rb` | `load '...wall_generation_test.rb'` |
| SketchUp版本兼容性 | `simple_reload.rb` | 使用简化版本，跳过工具栏管理 |

## 📖 详细文档

- **完整使用指南**: `../Zephyr_Wall_Tool_完整指南.md`
- **Length修复说明**: `../Length修复使用说明.md`
- **修复历史**: `../修复总结.md`

---

**提示**: 遇到问题时，请优先查看完整指南，那里有更详细的解决方案和故障排除步骤。 