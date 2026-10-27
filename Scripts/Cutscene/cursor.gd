extends CanvasLayer

@onready var sprite: Sprite2D = $Sprite2D

var _is_hovering: bool = false


func _ready() -> void:
	reset_cursor()


func _process(_delta: float) -> void:
	if sprite and sprite.visible:
		sprite.global_position = sprite.get_global_mouse_position()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_ENTER, NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_WM_WINDOW_FOCUS_IN:
			_apply_cursor_state()


func set_hover_cursor() -> void:
	_is_hovering = true
	_apply_cursor_state()


func reset_cursor() -> void:
	_is_hovering = false
	_apply_cursor_state()


func _apply_cursor_state() -> void:
	if not is_inside_tree():
		return
	if _is_hovering:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		if sprite:
			sprite.visible = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		if sprite:
			sprite.visible = false
