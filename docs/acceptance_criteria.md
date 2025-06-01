# Acceptance Criteria

## 1. 类型管理（Toolbox / Type Management）

- [ ] 用户能添加、编辑、删除墙体/天花类型，并看到类型属性（名称、颜色、厚度、高度、标签）在UI中正确显示  
      User can add, edit, and delete wall/ceiling types and see their attributes (name, color, thickness, height, tag) correctly displayed in the UI.
- [ ] 切换类型后，新绘制的墙体/天花自动应用选定类型的所有属性  
      When switching type, new wall/ceiling entities automatically apply all selected type properties.
- [ ] 类型顺序、属性变化能实时反映在工具箱和属性面板  
      Type order and property changes are instantly reflected in toolbox and property panels.

## 2. 多段线/多弧线绘制（Polyline Drawing）

- [ ] 用户可用多段线连续绘制墙体/天花，支持直线与圆弧混合，绘制过程无中断  
      User can draw walls/ceilings as continuous polylines, mixing lines and arcs, with uninterrupted workflow.
- [ ] 吸附锚点、锁定方向/轴（Shift/箭头）、输入距离/坐标功能与原生 Line Tool 一致  
      Endpoint snapping, axis/direction locking (Shift/Arrow), and distance/coordinate input all behave like the native Line Tool.
- [ ] 绘制结束时，所有墙体/天花 3D 结构、颜色、属性都正确生成并归类  
      On finish, all wall/ceiling 3D geometry, color, and attributes are generated and classified correctly.

## 3. 属性挂接与批量管理（Entity Attributes）

- [ ] 每个对象在 SketchUp 的 Attribute Dictionary 中完整保存类型、长度、面积、颜色等属性  
      Each entity fully stores type, length, area, color, etc., in the SketchUp Attribute Dictionary.
- [ ] 属性面板能正确读取、显示和批量修改对象属性  
      The property panel can correctly read, display, and batch-edit entity attributes.
- [ ] 用户修改属性后，模型和统计面板数据能立即同步  
      After attribute changes, the model and statistics panel data are instantly synchronized.

## 4. 实时统计与汇总（Statistics & Summary）

- [ ] 统计面板能实时显示各类型的总长度、面积和数量，切换筛选/排序无卡顿  
      The statistics panel shows real-time total length, area, and count for each type; switching filters/sorting is smooth.
- [ ] 任意墙体/天花变形、分割、删除后，统计自动刷新，无需手动操作  
      Any entity changes (reshape, split, delete) auto-refresh statistics with no manual action.

## 5. 数据导出（Data Export）

- [ ] 用户点击导出按钮后，能获得含全部字段的CSV，数据格式兼容Excel/表格软件  
      On export, user receives a CSV with all required fields, compatible with Excel/spreadsheets.
- [ ] 导出内容与统计面板数据完全一致，无遗漏或错误  
      Exported content matches the statistics panel exactly, with no missing or incorrect data.

## 6. 体验与高级功能（UX & Advanced）

- [ ] 工具箱和属性面板界面友好，支持键盘操作和搜索  
      Toolbox and property panel UI are user-friendly, supporting keyboard shortcuts and search.
- [ ] 支持类型模板导入导出、批量属性操作等进阶功能  
      Type template import/export and batch attribute operations are available as advanced features.
- [ ] 支持大模型流畅操作，属性和统计功能均无明显延迟  
      All features work smoothly even with large models; attribute and statistics functions show no noticeable lag.
- [ ] UI 支持中英文显示，国际化测试通过  
      UI supports both Chinese and English, with successful internationalization tests.

## 技术验收（Technical Acceptance）

- [ ] 墙体/天花均为 Group 实体，所有属性持久化到 Attribute Dictionary  
      All walls/ceilings are Group entities with attributes persisted in the Attribute Dictionary.
- [ ] 实时统计通过 Observer 机制自动联动，无需用户额外刷新  
      Real-time statistics use Observer mechanisms to auto-update, with no need for user refresh.
- [ ] 多段线/弧线数据结构设计合理，支持后期拆分、编辑  
      Polyline/arc data structures are well-designed, supporting future split/edit operations.
- [ ] CSV 导出采用 Ruby 标准库生成，字段顺序和类型一致  
      CSV export uses the Ruby standard library, with consistent field order and types.