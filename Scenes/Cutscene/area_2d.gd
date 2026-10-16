# Inside your Area2D script
extends Area2D

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	# Optional safety: reset cursor if the Area2D is destroyed while hovered
	tree_exiting.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	Cursor.set_hover_cursor()

func _on_mouse_exited() -> void:
	Cursor.reset_cursor()
