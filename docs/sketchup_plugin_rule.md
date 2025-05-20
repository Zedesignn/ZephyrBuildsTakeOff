# Zephyr SketchUp 插件开发规则（Rule）

## 1. SketchUp Ruby API 基本原则
- 所有 API 操作必须在主线程执行，避免不稳定和崩溃。
- 推荐使用 Group/Component 组织模型对象。
- 自定义数据建议存储在 Attribute Dictionary。
- 插件主入口文件需注册菜单和工具栏，便于用户访问。
- 插件打包为 .rbz，主入口文件和功能文件结构需清晰。

## 2. UI 交互与界面
- 使用 UI.menu('Extensions') 注册菜单，入口应在"Extensions"菜单下。
- 工具栏使用 UI::Toolbar + UI::Command 注册，支持图标、tooltip、状态栏提示。
- 支持 UI.inputbox、UI.messagebox、UI::HtmlDialog 等方式与用户交互。
- 类型管理、属性面板等建议后续升级为 HTMLDialog 实现更佳体验。

## 3. 类型管理（Type Management）
- 支持创建、编辑、删除墙体/天花类型，每种类型含：名称、颜色、厚度、高度、标签。
- 类型数据持久化存储于模型 Attribute Dictionary（如 WallTypes）。
- 类型属性的更改可实时应用到已绘制对象，支持批量修改。
- 类型库列表可视化展示，支持图标、拖动排序和搜索（后续HTMLDialog实现）。

## 4. 多段线/多弧线绘制（Polyline Drawing）
- 支持用多段线连续绘制墙体/天花，可混合直线和圆弧（如 Ctrl/Tab 切换模式）。
- 支持端点、中点、对象吸附，锁定方向/轴，与原生 Line Tool 行为一致。
- 支持输入距离/坐标，自动捕捉、修正输入点。
- 绘制完成时，自动生成3D结构，赋予当前激活类型的属性。

## 5. 属性与数据挂接（Entity Attributes）
- 每个墙体/天花对象必须存储：类型、长度、面积、厚度、高度、颜色、标签、创建/修改时间等属性。
- 支持属性面板查看、单个/批量编辑对象属性。
- 所有属性更改必须实时反映到模型和统计面板。

## 6. 实时统计与汇总（Statistics & Summary）
- 统计所有墙体/天花类型的总长度、面积、数量，支持分类型分组。
- 统计面板支持筛选、排序、类型高亮。
- 墙体/天花被修改（拉伸、变形、分割、删除）时，统计数据自动刷新。
- 推荐使用 EntitiesObserver/SelectionObserver 实现实时联动。

## 7. 数据导出（Data Export）
- 一键导出所有统计数据和对象属性为 CSV 文件，字段包括：类型、长度、面积、数量、厚度、高度、颜色、标签等。
- 导出数据格式需兼容 Excel/表格软件。
- 推荐使用 Ruby CSV 标准库。

## 8. 体验与高级功能（UX & Advanced）
- 类型管理、属性面板等 UI 需直观友好，支持国际化（多语言）。
- 支持类型模板导入导出、属性模板保存和应用。
- 支持对象高亮、属性跳转、撤销/重做等操作。
- 必须优化性能，支持大模型流畅操作。

## 9. 技术建议与最佳实践
- 工具开发可继承自 Tool 类，支持自定义鼠标交互、绘图、捕捉等。
- 推荐使用 TestUp 进行插件内单元测试。
- 推荐参考官方文档和示例：[SketchUp Ruby API](https://ruby.sketchup.com/)
- 插件结构建议：
  - 主入口：zephyr_wall_tool_loader.rb
  - 功能目录：zephyr_wall_tool/
    - core.rb（主功能）
    - images/（图标）
    - 其他功能模块
- 版本号建议独立维护 version.txt，打包时自动带入。 