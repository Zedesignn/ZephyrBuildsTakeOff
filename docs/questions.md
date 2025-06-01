# Questions

## 1. UI 设计与交互方式
- Toolbox（工具箱）和统计面板应采用何种具体 UI 技术？是 HtmlDialog、原生窗口还是第三方 UI 库？  
  What UI technology should be used for the Toolbox and statistics panel? HtmlDialog, native window, or third-party library?
- 属性面板与墙体对象的批量操作/选中体验需要额外优化吗？  
  Does the property panel and batch object selection/operation need further UX optimization?

## 2. 多段线与圆弧绘制
- 墙体/天花绘制中弧线段与直线段的切换方式用何种交互最直观？（如快捷键、右键菜单、UI按钮等）  
  What is the most intuitive way for users to switch between line and arc segments during polyline drawing (hotkey, context menu, UI button, etc.)?
- 多段线生成墙体时，曲线段如何处理 PushPull/拉伸以保证实体连续性？  
  How should arc segments be extruded (PushPull) to ensure continuous solid walls/ceilings?

## 3. 统计逻辑
- 是否需要支持非连续墙段自动识别并合并同类型统计？  
  Should non-contiguous wall segments of the same type be merged in the statistics?
- 天花（Ceiling）计量是否与墙体完全同逻辑，还是需要单独设计属性和汇总方式？  
  Should ceiling takeoff logic fully mirror walls, or does it require a separate attribute/statistics design?

## 4. 数据结构与扩展性
- 墙体/天花对象属性存储采用单一 Attribute Dictionary，还是拆分为多级字典以便后期扩展？  
  Should attributes be stored in a single Attribute Dictionary per entity, or split across multiple dictionaries for future extensibility?
- 如何为墙体添加更多自定义字段（如工艺类型、耐火等级等），并让统计/导出灵活扩展？  
  What is the best way to support additional custom fields (e.g., construction method, fire rating) for walls, ensuring extensible statistics/export?

## 5. 跨团队协作与版本兼容
- 插件是否需要支持云同步、多人协作或公司内部数据模板共享？  
  Should the plugin support cloud sync, multi-user collaboration, or company-wide type template sharing?
- 是否兼容 SketchUp 2020 之前的版本？  
  Is backward compatibility with SketchUp versions earlier than 2020 required?

## 6. 性能与极端场景
- 对于超大模型（如 >1万墙体/天花对象）是否需要做特殊的性能优化/分批加载方案？  
  Are there any special performance optimizations or batch loading strategies needed for extremely large models (10,000+ entities)?
- 撤销/重做对属性和统计联动是否有未覆盖的极端情况？  
  Are there any edge cases in undo/redo affecting attribute/statistics syncing that need additional handling?

## 7. 国际化与多语言支持
- 是否需要支持多语言（如中英切换、右到左语言等），后期是否计划全球发布？  
  Is multi-language (Chinese/English switching, RTL support, etc.) required, and is there a plan for global release?

## 8. 其他不确定项
- 插件是否需与其它 BIM/算量平台（如 Revit, CostX 等）做数据格式对接？  
  Should the plugin interface with other BIM/takeoff software (e.g., Revit, CostX) for data exchange?
- 用户期望导出的数据字段是否需要自定义配置？  
  Do users need to customize exported data fields, or is a fixed format sufficient?

---

> 建议将上述问题逐条提交给需求方、产品经理或核心用户澄清后再推进开发。
It is recommended to clarify these questions with stakeholders, product managers, or core users before proceeding with implementation.