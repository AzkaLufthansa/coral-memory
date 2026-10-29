extends Control

const FONT_PATH := "res://Assets/Fonts/Fusion Pixel 10px Monospaced/fusion-pixel-10px-monospaced-ja.otf"
const PANEL_WIDTH := 700.0

var _panel: PanelContainer
var _label: Label
var _marker: Label

var _pulse_tween: Tween
var _pulse_target: CanvasItem
var _pulse_base: Color = Color.WHITE


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	visible = false


func _build_ui() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.09, 0.11, 0.9)
	style.border_color = Color(0.85, 0.78, 0.55, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin(SIDE_LEFT, 20)
	style.set_content_margin(SIDE_RIGHT, 20)
	style.set_content_margin(SIDE_TOP, 10)
	style.set_content_margin(SIDE_BOTTOM, 10)

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_theme_stylebox_override("panel", style)
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.0
	_panel.anchor_bottom = 0.0
	_panel.offset_left = -PANEL_WIDTH * 0.5
	_panel.offset_right = PANEL_WIDTH * 0.5
	_panel.offset_top = 16
	_panel.offset_bottom = 16
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_END
	add_child(_panel)

	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_label.add_theme_font_size_override("font_size", 22)
	if ResourceLoader.exists(FONT_PATH):
		var font := load(FONT_PATH) as Font
		if font:
			_label.add_theme_font_override("font", font)
	_panel.add_child(_label)

	_marker = Label.new()
	_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marker.text = "▼"
	_marker.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25, 1))
	_marker.add_theme_font_size_override("font_size", 34)
	_marker.size = Vector2(40, 40)
	_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_marker.visible = false
	add_child(_marker)


func show_hint(text: String, target: Node) -> void:
	if _label:
		_label.text = text
	visible = true
	_position_marker(target)
	_start_pulse(target)


func hide_hint() -> void:
	_stop_pulse()
	visible = false


func _position_marker(target: Node) -> void:
	if _marker == null:
		return
	if target == null or not is_instance_valid(target):
		_marker.visible = false
		return

	var point := Vector2.ZERO
	if target is Control:
		var r: Rect2 = (target as Control).get_global_rect()
		point = Vector2(r.position.x + r.size.x * 0.5, r.position.y - 6)
	elif target is Node2D:
		point = (target as Node2D).get_global_transform_with_canvas().origin
		point.y -= 18
	else:
		_marker.visible = false
		return

	_marker.visible = true
	_marker.position = Vector2(point.x - _marker.size.x * 0.5, point.y - _marker.size.y)


func _start_pulse(target: Node) -> void:
	_stop_pulse()
	if target == null or not is_instance_valid(target):
		return
	var ci := target as CanvasItem
	if ci == null:
		return
	_pulse_target = ci
	_pulse_base = ci.modulate
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(ci, "modulate", Color(1.6, 1.5, 1.1, _pulse_base.a), 0.5)
	_pulse_tween.tween_property(ci, "modulate", _pulse_base, 0.5)


func _stop_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = null
	if _pulse_target and is_instance_valid(_pulse_target):
		_pulse_target.modulate = _pulse_base
	_pulse_target = null
