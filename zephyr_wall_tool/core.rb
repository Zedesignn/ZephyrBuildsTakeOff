require 'sketchup.rb'
require 'json'
require 'cgi'

module ZephyrWallTool
  TYPE_DICT = 'WallTypes'
  DEFAULT_TYPES = [
    { name: "默认墙体", color: "Red", thickness: 200.mm, height: 2800.mm, tag: "标准墙" }
  ]

  # 获取所有类型
  def self.all_types
    model = Sketchup.active_model
    
    # 检查是否有旧格式数据，如果有则清理
    old_data = model.get_attribute(TYPE_DICT, 'types')
    if old_data
      puts "Found old data format, clearing..."
      self.clear_old_data
    end
    
    # 获取类型数量
    type_count = model.get_attribute(TYPE_DICT, 'count', 0)
    puts "Found #{type_count} types in model"
    
    types = []
    
    if type_count == 0
      puts "No types found, creating default type"
      # 创建默认类型
      default_type = {
        name: "默认墙体",
        color: "Red", 
        thickness: 200.0.mm,
        height: 2800.0.mm,
        tag: "标准墙"
      }
      self.save_single_type(0, default_type)
      model.set_attribute(TYPE_DICT, 'count', 1)
      types << default_type
    else
      # 读取每个类型
      (0...type_count).each do |i|
        type = self.load_single_type(i)
        if type
          types << type
          puts "Loaded type #{i}: #{type[:name]}"
        else
          puts "Failed to load type #{i}"
        end
      end
    end
    
    puts "Returning #{types.length} types"
    types
  end

  # 保存单个类型
  def self.save_single_type(index, type)
    model = Sketchup.active_model
    prefix = "type_#{index}_"
    
    # 分别保存每个属性，确保单位正确
    model.set_attribute(TYPE_DICT, "#{prefix}name", type[:name].to_s)
    model.set_attribute(TYPE_DICT, "#{prefix}color", type[:color].to_s)
    model.set_attribute(TYPE_DICT, "#{prefix}thickness_mm", type[:thickness].to_mm.to_f)  # 转换为毫米数值
    model.set_attribute(TYPE_DICT, "#{prefix}height_mm", type[:height].to_mm.to_f)        # 转换为毫米数值
    model.set_attribute(TYPE_DICT, "#{prefix}tag", type[:tag].to_s)
    
    puts "Saved type #{index}: #{type[:name]} (#{type[:thickness].to_mm}mm x #{type[:height].to_mm}mm)"
  end

  # 加载单个类型
  def self.load_single_type(index)
    model = Sketchup.active_model
    prefix = "type_#{index}_"
    
    name = model.get_attribute(TYPE_DICT, "#{prefix}name")
    color = model.get_attribute(TYPE_DICT, "#{prefix}color") 
    thickness_mm = model.get_attribute(TYPE_DICT, "#{prefix}thickness_mm")
    height_mm = model.get_attribute(TYPE_DICT, "#{prefix}height_mm")
    tag = model.get_attribute(TYPE_DICT, "#{prefix}tag")
    
    if name && color && thickness_mm && height_mm && tag
      {
        name: name,
        color: color,
        thickness: thickness_mm.to_f.mm,  # 从毫米数值创建Length对象
        height: height_mm.to_f.mm,        # 从毫米数值创建Length对象
        tag: tag
      }
    else
      puts "Missing attributes for type #{index}: name=#{name}, color=#{color}, thickness_mm=#{thickness_mm}, height_mm=#{height_mm}, tag=#{tag}"
      nil
    end
  end

  # 保存所有类型
  def self.save_types(types)
    model = Sketchup.active_model
    puts "Saving #{types.length} types using individual attributes"
    
    # 先清除旧数据
    old_count = model.get_attribute(TYPE_DICT, 'count', 0)
    (0...old_count).each do |i|
      prefix = "type_#{i}_"
      model.delete_attribute(TYPE_DICT, "#{prefix}name")
      model.delete_attribute(TYPE_DICT, "#{prefix}color")
      model.delete_attribute(TYPE_DICT, "#{prefix}thickness_mm")
      model.delete_attribute(TYPE_DICT, "#{prefix}height_mm")
      model.delete_attribute(TYPE_DICT, "#{prefix}tag")
    end
    
    # 保存新数据
    types.each_with_index do |type, index|
      self.save_single_type(index, type)
    end
    
    # 更新数量
    model.set_attribute(TYPE_DICT, 'count', types.length)
    puts "Saved #{types.length} types successfully"
  end

  # macOS SketchUp 2024 专用方法：打开材质面板
  def self.open_materials_panel_macos
    success = false
    
    # macOS 专用方法1: 使用菜单触发
    begin
      # 尝试通过菜单系统打开材质窗口
      if defined?(UI.show_inspector)
        UI.show_inspector("Materials")
        success = true
        puts "Materials panel opened via show_inspector"
      end
    rescue => e
      puts "show_inspector failed: #{e}"
    end
    
    # macOS 专用方法2: 使用Cocoa特定的action
    unless success
      begin
        # macOS SketchUp 2024的材质窗口action ID
        Sketchup.send_action(10520)
        success = true
        puts "Materials panel opened via send_action 10520"
      rescue => e
        puts "send_action 10520 failed: #{e}"
      end
    end
    
    # macOS 专用方法3: 尝试激活Paint Bucket工具
    unless success
      begin
        Sketchup.send_action("selectPaintTool:")
        success = true
        puts "Paint bucket tool activated"
      rescue => e
        puts "selectPaintTool failed: #{e}"
      end
    end
    
    # 显示用户提示
    unless success
      UI.messagebox("请手动打开材质面板：\n菜单 > 窗口 > 默认面板 > 材质")
    end
    
    success
  end

  # macOS SketchUp 2024 专用方法：获取当前材质颜色
  def self.get_current_material_color_macos
    model = Sketchup.active_model
    found_color = nil
    debug_info = []
    
    # macOS 方法1: 检查materials.current
    begin
      current_material = model.materials.current
      if current_material && current_material.color
        found_color = current_material.color
        debug_info << "✓ Found via materials.current: #{found_color}"
      else
        debug_info << "✗ materials.current is nil or has no color"
      end
    rescue => e
      debug_info << "✗ materials.current error: #{e.message}"
    end
    
    # macOS 方法2: 检查模型中是否有材质可选择
    unless found_color
      begin
        materials = model.materials
        if materials.length > 0
          debug_info << "✓ Found #{materials.length} materials in model"
          # 显示材质选择对话框
          material_names = materials.map(&:display_name)
          choice = UI.inputbox(
            ["选择材质 (输入序号 1-#{materials.length}):"],
            ["1"],
            "模型中的材质:\n#{material_names.each_with_index.map{|name, i| "#{i+1}. #{name}"}.join("\n")}"
          )
          if choice && choice[0].to_i > 0 && choice[0].to_i <= materials.length
            selected_material = materials.to_a[choice[0].to_i - 1]
            found_color = selected_material.color
            debug_info << "✓ User selected material: #{selected_material.display_name}"
          else
            debug_info << "✗ User cancelled or invalid selection"
          end
        else
          debug_info << "✗ No materials in model"
        end
      rescue => e
        debug_info << "✗ Materials list error: #{e.message}"
      end
    end
    
    # macOS 方法3: 如果还是没有找到，给出使用说明
    unless found_color
      debug_info << "\n使用说明："
      debug_info << "1. 在材质面板中选择一个材质"
      debug_info << "2. 用油漆桶工具在模型中点击任意面"
      debug_info << "3. 再次点击'获取材质'按钮"
      debug_info << "\n或者使用预设颜色/自定义颜色"
    end
    
    puts debug_info.join("\n")
    return found_color, debug_info
  end

  # macOS SketchUp 2024 专用方法：创建测试面
  def self.create_test_face_macos
    model = Sketchup.active_model
    begin
      model.start_operation('创建测试面', true)
      
      # 创建一个简单的正方形面作为测试
      entities = model.entities
      face = entities.add_face([0,0,0], [1.m,0,0], [1.m,1.m,0], [0,1.m,0])
      
      if face
        # 将视图聚焦到这个面
        model.active_view.zoom(face)
        model.commit_operation
        UI.messagebox("已创建测试面！\n现在可以用油漆桶工具点击这个面来应用材质。")
        return true
      else
        model.abort_operation
        return false
      end
    rescue => e
      model.abort_operation
      puts "Create test face error: #{e.message}"
      return false
    end
  end

  # 创建WebDialog对话框
  def self.create_toolbox_dialog
    # 保持面板显示，不会因为失去焦点而隐藏
    dialog = UI::WebDialog.new(
      self.localize_text(:title),  # 使用本地化标题
      false,              # 不是模态对话框，允许与主窗口交互
      "ZephyrWallTool",   # 偏好设置键
      400,                # 宽度
      600,                # 高度
      200,                # X位置
      200,                # Y位置
      true                # 可调整大小
    )
    
    # 设置对话框行为，保持显示
    dialog.set_on_close {
      # 返回false阻止真正的关闭，这样面板不会消失
      false
    }
    
    # 设置对话框最小尺寸
    dialog.min_width = 350
    dialog.min_height = 500
    
    html_content = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { 
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif; 
            margin: 0; 
            background: #f5f5f5;
            font-size: 12px;
          }
          .title-bar {
            background: linear-gradient(to bottom, #f8f8f8, #e8e8e8);
            padding: 6px 12px;
            border-bottom: 1px solid #d0d0d0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: move;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
          }
          .title-text {
            font-weight: 600;
            color: #333;
            font-size: 13px;
          }
          .window-controls {
            display: flex;
            gap: 6px;
          }
          .control-btn {
            width: 13px;
            height: 13px;
            border-radius: 50%;
            border: 0.5px solid rgba(0,0,0,0.2);
            cursor: pointer;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.3);
          }
          .minimize-btn { background: linear-gradient(to bottom, #ffdb4c, #ffcd02); }
          .maximize-btn { background: linear-gradient(to bottom, #3fc950, #57d038); }
          .content {
            padding: 12px;
            background: white;
            transition: all 0.3s ease;
          }
          .content.minimized {
            display: none;
          }
          .toolbar { 
            margin-bottom: 12px; 
            display: flex;
            gap: 8px;
          }
          .toolbar button {
            background: linear-gradient(to bottom, #fafafa, #e8e8e8);
            border: 1px solid #c0c0c0;
            border-radius: 3px;
            padding: 4px 8px;
            font-size: 11px;
            cursor: pointer;
            box-shadow: 0 1px 1px rgba(0,0,0,0.05);
          }
          .toolbar button:hover {
            background: linear-gradient(to bottom, #f0f0f0, #d8d8d8);
          }
          .toolbar button:active {
            background: linear-gradient(to bottom, #d8d8d8, #e8e8e8);
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.1);
          }
          .type-list { 
            border: 1px solid #d0d0d0; 
            padding: 8px; 
            margin-bottom: 12px; 
            max-height: 300px; 
            overflow-y: auto;
            background: white;
            border-radius: 3px;
          }
          .type-item { 
            padding: 6px 8px; 
            margin: 2px 0; 
            border: 1px solid #e8e8e8;
            cursor: pointer;
            border-radius: 3px;
            font-size: 11px;
            background: #fafafa;
            transition: all 0.2s ease;
          }
          .type-item:hover { 
            background: #f0f8ff; 
            border-color: #b8d4f0;
          }
          .type-item.selected { 
            background: linear-gradient(to bottom, #4a90e2, #357abd); 
            color: white; 
            border-color: #2968a3;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.2);
          }
          .native-mode {
            text-align: center;
            padding: 20px;
            background: #f8f8f8;
            border-radius: 3px;
            margin-bottom: 12px;
          }
          .native-btn {
            background: linear-gradient(to bottom, #4a90e2, #357abd);
            color: white;
            border: none;
            border-radius: 3px;
            padding: 8px 16px;
            font-size: 12px;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
          }
          .native-btn:hover {
            background: linear-gradient(to bottom, #5ba0f2, #4080cd);
          }
          .color-preview {
            width: 16px;
            height: 16px;
            display: inline-block;
            border: 1px solid #999;
            vertical-align: middle;
            margin-left: 6px;
            border-radius: 2px;
            box-shadow: inset 0 1px 1px rgba(0,0,0,0.1);
          }
        </style>
      </head>
      <body>
        <div class="title-bar">
          <div class="title-text">墙体类型工具箱</div>
          <div class="window-controls">
            <button class="control-btn minimize-btn" onclick="toggleMinimize()" title="最小化"></button>
            <button class="control-btn maximize-btn" onclick="toggleMaximize()" title="置顶"></button>
          </div>
        </div>
        <div class="content" id="mainContent">
          <div class="native-mode">
            <button class="native-btn" onclick="useNativeDialog()">使用原生对话框添加</button>
            <div style="margin-top: 8px; font-size: 10px; color: #666;">
              使用SketchUp原生界面风格
            </div>
          </div>
          
          <div class="toolbar">
            <button onclick="showAddForm()">网页版添加</button>
            <button onclick="deleteSelected()">删除选中</button>
          </div>
          <div id="typeList" class="type-list"></div>
          <div id="addForm" style="display: none;">
            <div class="form-group">
              <label>类型名称:</label>
              <input type="text" id="typeName">
            </div>
            <div class="form-group">
              <label>颜色选择:</label>
              <div class="color-buttons">
                <button onclick="openMaterialsPanel()">材质面板</button>
                <button onclick="getMaterialColor()">获取材质</button>
                <button onclick="inputCustomColor()">自定义</button>
              </div>
              <div class="color-buttons">
                <button onclick="createTestFace()" style="background: #f0f8ff;">创建测试面</button>
                <small style="color: #666;">用于测试材质的临时面</small>
              </div>
              <div class="color-presets">
                <div class="color-preset" style="background-color: #FF0000;" onclick="setPresetColor('#FF0000')" title="红色"></div>
                <div class="color-preset" style="background-color: #0000FF;" onclick="setPresetColor('#0000FF')" title="蓝色"></div>
                <div class="color-preset" style="background-color: #00FF00;" onclick="setPresetColor('#00FF00')" title="绿色"></div>
                <div class="color-preset" style="background-color: #FFFF00;" onclick="setPresetColor('#FFFF00')" title="黄色"></div>
                <div class="color-preset" style="background-color: #FF8000;" onclick="setPresetColor('#FF8000')" title="橙色"></div>
                <div class="color-preset" style="background-color: #8000FF;" onclick="setPresetColor('#8000FF')" title="紫色"></div>
                <div class="color-preset" style="background-color: #804000;" onclick="setPresetColor('#804000')" title="棕色"></div>
                <div class="color-preset" style="background-color: #808080;" onclick="setPresetColor('#808080')" title="灰色"></div>
              </div>
              <div id="colorPreview" class="color-preview" style="background-color: #808080;"></div>
              <input type="hidden" id="typeColor" value="#808080">
            </div>
            <div class="form-group">
              <label>厚度 (mm):</label>
              <input type="number" id="typeThickness" value="200">
            </div>
            <div class="form-group">
              <label>高度 (mm):</label>
              <input type="number" id="typeHeight" value="2800">
            </div>
            <div class="form-group">
              <label>标签:</label>
              <input type="text" id="typeTag">
            </div>
            <button onclick="addType()">保存</button>
            <button onclick="hideAddForm()">取消</button>
          </div>
          <script>
            let selectedTypeIndex = -1;
            
            function updateTypeList(types) {
              console.log('updateTypeList called with:', types);
              console.log('Types count:', types.length);
              
              const list = document.getElementById('typeList');
              if (!list) {
                console.error('typeList element not found!');
                return;
              }
              
              list.innerHTML = '';
              types.forEach((type, index) => {
                console.log('Adding type:', type);
                const div = document.createElement('div');
                div.className = 'type-item';
                div.onclick = () => selectType(index);
                div.innerHTML = `
                  <strong>${type.name}</strong>
                  <div class="color-preview" style="background-color: ${type.color};"></div><br>
                  厚度: ${Math.round(type.thickness)}mm | 高度: ${Math.round(type.height)}mm<br>
                  标签: ${type.tag}
                `;
                list.appendChild(div);
              });
              console.log('typeList updated, children count:', list.children.length);
            }
            
            function selectType(index) {
              selectedTypeIndex = index;
              document.querySelectorAll('.type-item').forEach((item, i) => {
                item.className = i === index ? 'type-item selected' : 'type-item';
              });
            }
            
            function showAddForm() {
              document.getElementById('addForm').style.display = 'block';
              document.getElementById('typeName').value = '';
              document.getElementById('typeColor').value = '#808080';
              document.getElementById('colorPreview').style.backgroundColor = '#808080';
              document.getElementById('typeThickness').value = '200';
              document.getElementById('typeHeight').value = '2800';
              document.getElementById('typeTag').value = '';
            }
            
            function hideAddForm() {
              document.getElementById('addForm').style.display = 'none';
            }
            
            function openMaterialsPanel() {
              window.location.href = 'skp:openMaterialsPanel@';
            }
            
            function getMaterialColor() {
              window.location.href = 'skp:getMaterialColor@';
            }
            
            function inputCustomColor() {
              window.location.href = 'skp:inputCustomColor@';
            }
            
            function setPresetColor(color) {
              setColor(color);
            }
            
            function setColor(color) {
              document.getElementById('typeColor').value = color;
              document.getElementById('colorPreview').style.backgroundColor = color;
            }
            
            function addType() {
              console.log('addType function called');
              
              const name = document.getElementById('typeName').value;
              const color = document.getElementById('typeColor').value;
              const thickness = document.getElementById('typeThickness').value;
              const height = document.getElementById('typeHeight').value;
              const tag = document.getElementById('typeTag').value;
              
              console.log('Form values:', { name, color, thickness, height, tag });
              
              if (!name.trim()) {
                alert('请输入类型名称');
                return;
              }
              
              const url = 'skp:addType@' + encodeURIComponent(name) + ',' + encodeURIComponent(color) + ',' + encodeURIComponent(thickness) + ',' + encodeURIComponent(height) + ',' + encodeURIComponent(tag);
              console.log('Calling Ruby with URL:', url);
              
              window.location.href = url;
              hideAddForm();
              console.log('addType completed');
            }
            
            function deleteSelected() {
              if (selectedTypeIndex === -1) {
                alert('请先选择一个类型');
                return;
              }
              if (confirm('确定要删除选中的类型吗？')) {
                window.location.href = 'skp:deleteType@' + selectedTypeIndex;
              }
            }
            
            function createTestFace() {
              window.location.href = 'skp:createTestFace@';
            }
            
            function useNativeDialog() {
              window.location.href = 'skp:useNativeDialog@';
            }
            
            let isMinimized = false;
            function toggleMinimize() {
              const content = document.getElementById('mainContent');
              isMinimized = !isMinimized;
              if (isMinimized) {
                content.style.display = 'none';
                window.location.href = 'skp:setMinimized@true';
              } else {
                content.style.display = 'block';
                window.location.href = 'skp:setMinimized@false';
              }
            }
            
            function toggleMaximize() {
              window.location.href = 'skp:toggleStayOnTop@';
            }
            
            // 初始化
            window.onload = function() {
              window.updateTypeList = updateTypeList;
              updateTypeList(#{self.types_for_js(self.all_types).to_json});
            }
          </script>
        </div>
      </body>
      </html>
    HTML
    dialog.set_html(html_content)
    
    dialog.add_action_callback("addType") { |action_context, params|
      puts "addType callback triggered with params: #{params}"
      
      begin
        name, color, thickness, height, tag = params.split(',').map { |v| CGI.unescape(v) }
        puts "Parsed values: name=#{name}, color=#{color}, thickness=#{thickness}, height=#{height}, tag=#{tag}"
        
        types = self.all_types
        puts "Current types count: #{types.length}"
        
        new_type = {
          name: name,
          color: color,
          thickness: thickness.to_f.mm,
          height: height.to_f.mm,
          tag: tag
        }
        puts "New type created: #{new_type}"
        
        types << new_type
        puts "Types count after adding: #{types.length}"
        puts "New type being added: #{new_type.inspect}"
        
        self.save_types(types)
        
        # 确保更新列表
        updated_types = self.all_types
        puts "Updated types count: #{updated_types.length}"
        
        types_json = self.types_for_js(updated_types).to_json
        puts "Sending to JS: #{types_json}"
        
        dialog.execute_script("updateTypeList(#{types_json})")
        puts "execute_script called successfully"
        
      rescue => e
        puts "Error in addType: #{e.message}"
        puts e.backtrace
        UI.messagebox("保存失败: #{e.message}")
      end
    }
    
    dialog.add_action_callback("deleteType") { |action_context, index|
      types = self.all_types
      types.delete_at(index.to_i)
      self.save_types(types)
      dialog.execute_script("updateTypeList(#{self.types_for_js(types).to_json})")
    }
    
    dialog.add_action_callback("openMaterialsPanel") { |action_context|
      self.open_materials_panel_macos
    }
    
    dialog.add_action_callback("getMaterialColor") { |action_context|
      color, debug_info = self.get_current_material_color_macos
      if color
        # 转换颜色为十六进制格式
        if color.is_a?(Sketchup::Color)
          hex_color = sprintf("#%02X%02X%02X", color.red, color.green, color.blue)
        else
          hex_color = color.to_s
        end
        dialog.execute_script("setColor('#{hex_color}')")
      else
        UI.messagebox("无法获取材质颜色\n\n调试信息:\n#{debug_info.join("\n")}\n\n请使用预设颜色或自定义颜色")
      end
    }
    
    dialog.add_action_callback("inputCustomColor") { |action_context|
      result = UI.inputbox(
        ["颜色名称或十六进制值 (如: Red, #FF0000):"], 
        ["#FF0000"], 
        "输入自定义颜色"
      )
      if result && !result[0].empty?
        color_input = result[0].strip
        dialog.execute_script("setColor('#{color_input}')")
      end
    }
    
    dialog.add_action_callback("useNativeDialog") { |action_context|
      # 使用原生对话框添加类型
      self.native_add_type_dialog
    }
    
    dialog.add_action_callback("createTestFace") { |action_context|
      if self.create_test_face_macos
        # 测试面创建成功，不需要额外提示，create_test_face_macos方法中已有提示
      else
        UI.messagebox("无法创建测试面。请确认模型处于可编辑状态。")
      end
    }
    
    dialog.add_action_callback("setMinimized") { |action_context, minimized|
      # 在macOS上，我们可以调整窗口大小来模拟最小化
      if minimized == "true"
        dialog.set_size(400, 40)  # 只显示标题栏
      else
        dialog.set_size(400, 600) # 恢复正常大小
      end
    }
    
    dialog.add_action_callback("toggleStayOnTop") { |action_context|
      # 尝试让窗口保持在最前面（这在不同SketchUp版本中可能有不同效果）
      begin
        dialog.bring_to_front
        UI.messagebox("已尝试将面板置顶", MB_OK)
      rescue => e
        puts "Stay on top error: #{e.message}"
      end
    }
    
    dialog.show
    
    # 存储对话框引用，方便后续操作
    @@current_dialog = dialog
  end

  # 类型管理主入口
  def self.manage_types
    # 如果对话框已存在，直接显示
    if defined?(@@current_dialog) && @@current_dialog
      begin
        @@current_dialog.bring_to_front
        @@current_dialog.show
        return
      rescue => e
        puts "Error bringing dialog to front: #{e.message}"
        # 如果出错，创建新的对话框
        @@current_dialog = nil
      end
    end
    
    # 创建新的对话框
    self.create_toolbox_dialog
  end

  # 为JavaScript准备数据（转换Length为毫米数值）
  def self.types_for_js(runtime_types)
    runtime_types.map do |type|
      {
        name: type[:name],
        color: type[:color],
        thickness: type[:thickness].to_mm.to_f,  # 明确转换为毫米数值
        height: type[:height].to_mm.to_f,        # 明确转换为毫米数值
        tag: type[:tag]
      }
    end
  end

  # 清理旧的存储数据，强制使用新系统
  def self.clear_old_data
    model = Sketchup.active_model
    puts "Clearing old data format..."
    
    # 删除旧的数组格式存储
    model.delete_attribute(TYPE_DICT, 'types')
    
    # 强制重置计数器
    model.set_attribute(TYPE_DICT, 'count', 0)
    
    puts "Old data cleared, will recreate using new format"
  end

  # 获取SketchUp语言设置
  def self.get_sketchup_language
    # SketchUp的语言代码
    begin
      locale = Sketchup.get_locale
      puts "SketchUp locale: #{locale}"
      locale
    rescue
      "en" # 默认英语
    end
  end

  # 本地化文本
  def self.localize_text(key)
    locale = self.get_sketchup_language
    
    texts = {
      "zh" => {
        title: "墙体类型工具箱",
        add_type: "新建类型",
        delete_type: "删除选中",
        type_name: "类型名称",
        thickness: "厚度 (mm)",
        height: "高度 (mm)", 
        tag: "标签",
        color: "颜色",
        save: "保存",
        cancel: "取消",
        select_material: "选择材质",
        custom_color: "自定义颜色"
      },
      "en" => {
        title: "Wall Type Toolbox",
        add_type: "Add Type",
        delete_type: "Delete Selected",
        type_name: "Type Name",
        thickness: "Thickness (mm)",
        height: "Height (mm)",
        tag: "Tag", 
        color: "Color",
        save: "Save",
        cancel: "Cancel",
        select_material: "Select Material",
        custom_color: "Custom Color"
      }
    }
    
    lang = texts[locale] || texts["en"]
    lang[key] || key.to_s
  end

  # 原生风格的类型添加对话框
  def self.native_add_type_dialog
    texts = {
      type_name: self.localize_text(:type_name),
      thickness: self.localize_text(:thickness),
      height: self.localize_text(:height),
      tag: self.localize_text(:tag),
      title: self.localize_text(:add_type)
    }
    
    # 使用SketchUp原生inputbox，样式更接近Entity Info
    prompts = [
      texts[:type_name],
      texts[:thickness], 
      texts[:height],
      texts[:tag]
    ]
    
    defaults = ["新墙体类型", "200", "2800", "标准"]
    
    results = UI.inputbox(prompts, defaults, texts[:title])
    
    if results
      name, thickness, height, tag = results
      
      # 颜色选择使用单独的对话框
      color = self.native_color_picker
      
      if color
        new_type = {
          name: name,
          color: color,
          thickness: thickness.to_f.mm,
          height: height.to_f.mm,
          tag: tag
        }
        
        # 添加到现有类型
        types = self.all_types
        types << new_type
        self.save_types(types)
        
        # 刷新当前对话框
        if defined?(@@current_dialog) && @@current_dialog
          updated_types = self.all_types
          @@current_dialog.execute_script("updateTypeList(#{self.types_for_js(updated_types).to_json})")
        end
        
        UI.messagebox("类型 '#{name}' 添加成功！")
        return true
      end
    end
    
    false
  end

  # 原生风格的颜色选择器
  def self.native_color_picker
    model = Sketchup.active_model
    
    # 方法1: 尝试获取当前材质
    current_material = model.materials.current
    if current_material && current_material.color
      choice = UI.messagebox(
        "使用当前选中的材质 '#{current_material.display_name}' 吗？", 
        MB_YESNOCANCEL
      )
      
      case choice
      when IDYES
        return sprintf("#%02X%02X%02X", 
          current_material.color.red, 
          current_material.color.green, 
          current_material.color.blue)
      when IDCANCEL
        return nil
      end
    end
    
    # 方法2: 从模型中的材质选择
    materials = model.materials.to_a
    if materials.length > 0
      material_names = materials.map.with_index { |mat, i| "#{i+1}. #{mat.display_name}" }
      choice = UI.inputbox(
        ["选择材质 (输入序号):"],
        ["1"],
        "模型材质:\n#{material_names.join("\n")}"
      )
      
      if choice && choice[0].to_i > 0 && choice[0].to_i <= materials.length
        selected_material = materials[choice[0].to_i - 1]
        return sprintf("#%02X%02X%02X", 
          selected_material.color.red, 
          selected_material.color.green, 
          selected_material.color.blue)
      end
    end
    
    # 方法3: 手动输入颜色
    color_choice = UI.inputbox(
      ["颜色 (名称或#RRGGBB):"],
      ["#808080"],
      "颜色选择"
    )
    
    if color_choice && !color_choice[0].empty?
      return color_choice[0]
    end
    
    nil
  end

  # 移除了这里的 unless file_loaded?(__FILE__) 块，因为它包含了重复的菜单和工具栏注册代码
  # UI注册现在统一由 zephyr_wall_tool_loader.rb 处理
end