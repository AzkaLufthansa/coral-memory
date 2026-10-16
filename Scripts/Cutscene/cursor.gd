extends CanvasLayer

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Hide the native operating system cursor
	reset_cursor()

func _process(_delta: float) -> void:
	# Move the sprite to the global mouse position every frame
	sprite.global_position = sprite.get_global_mouse_position()

func _notification(what: int) -> void:
	# Ensure the cursor stays hidden when clicking back into the game window
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func set_hover_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	sprite.visible = true

func reset_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	sprite.visible = false
