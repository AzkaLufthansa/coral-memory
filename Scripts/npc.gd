extends CharacterBody2D

@export var move_speed: float = 80.0
@export var stop_distance: float = 5.0

@onready var target: Marker2D = get_tree().get_first_node_in_group("Titik")
@onready var sprite: Sprite2D = $Sprite2D

enum State { APPROACHING, WAITING, LEAVING }
var current_state: State = State.APPROACHING

func _physics_process(_delta: float) -> void:
	if not target:
		return
		
	if current_state == State.APPROACHING:
		var direction: Vector2 = (target.global_position - global_position).normalized()
		var distance: float = global_position.distance_to(target.global_position)
		
		sprite.flip_h = direction.x < 0
		
		if distance > stop_distance:
			velocity = direction * move_speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			current_state = State.WAITING
			_on_reached_window()

func _on_reached_window() -> void:
	print("NPC sampai di jendela!")
