# test_sketchup_api.rb
# 这是一个在 SketchUp Ruby 控制台中运行的示例脚本。
# 在您的 IDE 中（如 VS Code 配置了 Solargraph），当您输入 Sketchup. active_model 时，
# 或者在获取了 model 对象后输入 model. 时，应该能看到相关的 API 提示。

# 确保此代码在 SketchUp 环境中执行，或者您的 IDE 已正确配置 Solargraph 和 sketchup-api-stubs

# 尝试获取当前模型
# 当输入 "Sketchup." 时，IDE 应该提示 "active_model" 等
# mod = Sketchup.active_model

# 如果 Sketchup.active_model 成功获取模型对象 (mod 不是 nil)
# 当输入 "mod." 时，IDE 应该提示 "entities", "selection", "materials" 等
# ents = mod.entities

# 当输入 "ents." 时，IDE 应该提示 "add_face", "add_line", "add_cpoint" 等

# 另一个例子：
# view = Sketchup.active_model.active_view
# 当输入 "view." 时，是否能看到像 "camera", "draw_points" 等方法？

UI.messagebox("请在您的 IDE 中打开此文件，并尝试输入 SketchUp API 代码，例如在下面输入 'Sketchup.' 或 'model.' 来观察自动补全是否工作。")

# 在下面开始输入，例如：
# Sketchup.
# model = Sketchup.active_model
# model.
# ents = model.entities
# ents.
# view = model.active_view
# view.
# sk