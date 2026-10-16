extends Camera2D

# --- Settings ---
@export_group("Follow / Peeking")
@export_range(0.0, 1.0) var peek_factor: float = 0.2 # How much the camera follows the mouse (0 = none, 0.5 = halfway)
@export var movement_smoothing: float = 10.0

@export_group("Edge Panning")
@export var edge_pan_speed: float = 800.0
@export var edge_margin: float = 40.0 # Pixels from edge to trigger pan

@export_group("Zoom")
@export var zoom_smoothing: float = 10.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 4.0

@export_group("Limits")
@export var enable_bounds: bool = true
@export var bounds_rect: Rect2 = Rect2(-2000, -2000, 4000, 4000)

# --- Internal State ---
var _target_zoom: float
var _base_position: Vector2 # The "center" of the camera before peeking

func _ready() -> void:
	_target_zoom = zoom.x
	_base_position = position
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _process(delta: float) -> void:
	# 1. Handle Edge Panning (Moving the base position)
	var viewport_rect = get_viewport().get_visible_rect()
	var mouse_pos = get_viewport().get_mouse_position()
	
	var move_vec = Vector2.ZERO
	
	# Check edges
	if mouse_pos.x < edge_margin:
		move_vec.x -= 1.0
	elif mouse_pos.x > viewport_rect.size.x - edge_margin:
		move_vec.x += 1.0
		
	if mouse_pos.y < edge_margin:
		move_vec.y -= 1.0
	elif mouse_pos.y > viewport_rect.size.y - edge_margin:
		move_vec.y += 1.0
	
	if move_vec != Vector2.ZERO:
		move_vec = move_vec.normalized()
		# Move the base position
		_base_position += move_vec * (edge_pan_speed * delta) / zoom.x
		_clamp_base_position()

	# 2. Calculate "Peek" Offset (Following the cursor)
	# Find distance from screen center to mouse
	var center_screen = viewport_rect.size / 2.0
	var mouse_offset_from_center = mouse_pos - center_screen
	
	# Scale this offset by zoom (so it feels consistent) and the peek factor
	var peek_offset = mouse_offset_from_center * peek_factor / zoom.x
	
	# 3. Apply Smoothing
	var final_target_pos = _base_position + peek_offset
	
	# Smoothly move actual position to target
	position = lerp(position, final_target_pos, 1.0 - exp(-movement_smoothing * delta))
	
	# Smoothly zoom
	var new_zoom = lerp(zoom.x, _target_zoom, 1.0 - exp(-zoom_smoothing * delta))
	zoom = Vector2(new_zoom, new_zoom)

func _unhandled_input(event: InputEvent) -> void:
	# --- Zooming ---
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(1.0 + zoom_step, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(1.0 / (1.0 + zoom_step), event.position)

func _zoom_camera(factor: float, mouse_pixel_pos: Vector2) -> void:
	var prev_zoom = _target_zoom
	_target_zoom = clamp(prev_zoom * factor, min_zoom, max_zoom)
	
	if prev_zoom == _target_zoom: return

	# Adjust the BASE position to zoom towards cursor
	# (We ignore the peek offset here to keep the "center" stable)
	var viewport_size = get_viewport_rect().size
	var center_offset = mouse_pixel_pos - viewport_size / 2.0
	var zoom_ratio = 1.0 / prev_zoom - 1.0 / _target_zoom
	var pos_offset = center_offset * zoom_ratio
	
	_base_position += pos_offset
	_clamp_base_position()

func _clamp_base_position() -> void:
	if not enable_bounds: return
	
	# We clamp the BASE position, not the peek position.
	# This allows the camera to "peek" slightly outside the bounds, 
	# which usually feels better than hitting a hard wall.
	
	var view_size = get_viewport_rect().size / _target_zoom
	var view_half_size = view_size / 2.0
	var min_pos = bounds_rect.position + view_half_size
	var max_pos = bounds_rect.end - view_half_size
	
	if min_pos.x > max_pos.x:
		_base_position.x = bounds_rect.position.x + bounds_rect.size.x / 2.0
	else:
		_base_position.x = clamp(_base_position.x, min_pos.x, max_pos.x)
		
	if min_pos.y > max_pos.y:
		_base_position.y = bounds_rect.position.y + bounds_rect.size.y / 2.0
	else:
		_base_position.y = clamp(_base_position.y, min_pos.y, max_pos.y)

func _draw():
	if Engine.is_editor_hint() and enable_bounds:
		draw_rect(bounds_rect, Color.YELLOW, false, 2.0)
