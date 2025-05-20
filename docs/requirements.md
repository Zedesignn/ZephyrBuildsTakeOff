# Requirements

## 1. 类型管理（Toolbox / Type Management）

- 必须支持创建、编辑、删除墙体/天花类型，每种类型含：名称、颜色、厚度、高度、标签（tag）
  - Must allow users to create, edit, and delete wall/ceiling types, each with: name, color, thickness, height, tag.
- 类型库列表可视化展示，支持图标、拖动排序和搜索
  - Types must be displayed visually in a toolbox list, supporting icons, drag & drop sorting, and search.
- 类型属性的更改可实时应用到已绘制对象（支持批量修改）
  - Changes to type properties must update existing objects, supporting batch edits.

## 2. 多段线/多弧线绘制（Polyline Drawing）

- 必须支持用多段线连续绘制墙体/天花，且可混合直线和圆弧（如 Ctrl/Tab 切换模式）
  - Must support drawing continuous polylines with mixed line and arc segments (e.g., switch with Ctrl/Tab).
- 必须支持端点、中点、对象吸附，锁定方向/轴（Shift/箭头），与原生 Line Tool 行为一致
  - Must support endpoint/midpoint/object snapping, direction/axis locking (Shift/Arrow), matching native Line Tool experience.
- 必须支持输入距离/坐标，自动捕捉、修正输入点
  - Must support distance/coordinate input, with auto-snap and correction.
- 墙体/天花绘制完成时，自动生成3D结构，赋予当前激活类型的属性
  - Upon finishing, must auto-generate 3D geometry with all relevant type attributes.

## 3. 属性与数据挂接（Entity Attributes）

- 每个墙体/天花对象必须存储：类型、长度、面积、厚度、高度、颜色、标签、创建/修改时间等属性（Attribute Dictionary）
  - Each wall/ceiling entity must store: type, length, area, thickness, height, color, tag, create/update timestamp, etc. (in Attribute Dictionary)
- 支持属性面板查看、单个/批量编辑对象属性
  - Must support a property panel to view and edit attributes, singly or in batch.
- 所有属性更改必须实时反映到模型和统计面板
  - All attribute changes must be immediately reflected in the model and statistics.

## 4. 实时统计与汇总（Statistics & Summary）

- 必须统计所有墙体/天花类型的总长度、面积、数量，支持分类型分组
  - Must compute total length, area, and count for each wall/ceiling type, with grouped display.
- 统计面板必须支持筛选、排序、类型高亮
  - Statistics panel must allow filtering, sorting, and highlighting by type.
- 墙体/天花被修改（拉伸、变形、分割、删除）时，统计数据自动刷新
  - When entities are modified (stretch, reshape, split, delete), stats must auto-refresh.

## 5. 数据导出（Data Export）

- 必须一键导出所有统计数据和对象属性为 CSV 文件，字段包括：类型、长度、面积、数量、厚度、高度、颜色、标签等
  - Must allow one-click export of all statistics and attributes as a CSV file, including: type, length, area, count, thickness, height, color, tag, etc.
- 导出数据格式需兼容 Excel/表格软件
  - Export format must be Excel/spreadsheet compatible.

## 6. 体验与高级功能（UX & Advanced）

- Toolbox 类型管理、属性面板等 UI 需直观友好，支持国际化（多语言）
  - Toolbox/type management and property panel UI must be intuitive and support internationalization.
- 支持类型模板导入导出、属性模板保存和应用
  - Must support import/export of type templates and attribute presets.
- 支持对象高亮、属性跳转、撤销/重做等操作
  - Must support object highlighting, attribute jump, undo/redo, etc.
- 必须考虑性能优化，支持大模型流畅操作
  - Must be optimized for performance to handle large models smoothly.

## 技术建议（Technical Notes）

- 墙体/天花对象建议全部用 Group，并用 Attribute Dictionary 存储属性
  - Recommend using Groups for entities and Attribute Dictionary for metadata
- 实时统计与联动建议使用 EntitiesObserver/SelectionObserver 机制
  - Recommend using EntitiesObserver/SelectionObserver for live stats and syncing
- 多段线/多弧线数据结构需设计为便于后期拆分、合并与编辑
  - Polyline/arc data structures should support easy splitting, merging, and editing
- 所有导出功能建议使用 Ruby CSV 标准库
  - Export functionality should use Ruby’s CSV standard library