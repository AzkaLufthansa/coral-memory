extends Node2D

signal bell_clicked
signal book_clicked
signal monitor_clicked

@onready var bell_area: Area2D = $BellArea
@onready var book_area: Area2D = $ExaminationBookArea
@onready var monitor_area: Area2D = $BellArea4


func _ready() -> void:
	_setup_clickable(bell_area, func() -> void: bell_clicked.emit())
	_setup_clickable(book_area, func() -> void: book_clicked.emit())
	_setup_clickable(monitor_area, func() -> void: monitor_clicked.emit())


func _setup_clickable(area: Area2D, on_click: Callable) -> void:
	if area == null:
		return
	area.input_event.connect(func(_viewport: Node, event: InputEvent, _shape: int) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			on_click.call()
	)
