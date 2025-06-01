# Problem

目前 SketchUp 缺乏类似 Bluebeam Revu Tool Chest 的专业墙体/天花类型管理与计量工具。  
Currently, SketchUp lacks a professional takeoff and wall management tool comparable to Bluebeam Revu’s Tool Chest.

现有插件无法满足下列核心需求：  
There is currently no plugin that allows users to:

- 自定义墙体和天花类型，并能灵活编辑其属性（如厚度、高度、颜色、标签等）  
  Define custom wall and ceiling types with editable properties (thickness, height, color, tag, etc.)
- 用多段线（直线+弧线混合），像原生Line Tool一样支持吸附、锁定方向、坐标输入，快速绘制墙体/天花  
  Draw walls/ceilings using mixed polylines (line + arc segments) with full snapping, direction locking, and coordinate entry like the native Line Tool
- 提供像Toolbox的UI，可以保存、管理、快速切换墙体/天花类型  
  Store, manage, and quickly switch between wall/ceiling types via a toolbox-style UI
- 自动为每段墙体/天花实例打上类型及相关元数据（长度、面积、类型等），并在修改后同步更新  
  Automatically attach and update metadata (length, area, type, etc.) to each wall/ceiling entity, keeping it in sync after edits
- 实时统计各类型的墙体/天花总长度、面积与数量，支持按类型分组查看  
  Perform real-time, per-type statistics for length, area, and count
- 所有统计数据在墙体几何形状被用户修改后自动刷新，保证计量准确  
  Sync wall stats automatically after manual geometry edits, ensuring takeoff data is always accurate
- 一键导出统计与对象属性为 CSV 以便后续BIM/施工分析  
  Export all statistical data in CSV for further processing

缺乏这类插件，导致建筑、施工用户在量算和出图流转时效率低、易出错，不能很好支持精确的墙体/天花计量、报价、复核等实际工程需求。  
The lack of such a plugin leads to inefficiency and error-proneness in takeoff workflows for architectural and construction users who rely on precise wall/ceiling quantification and documentation.