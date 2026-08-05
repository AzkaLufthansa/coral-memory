extends Control

signal inspect_closed

@onready var echo_view: Echo2D = %EchoView
@onready var hint_label: Label = %HintLabel


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func show_for(patient: PatientData, source_echo: Echo2D) -> void:
	# Tampilkan salinan echo yang sama besar di tengah layar.
	echo_view.apply_reveal_levels(source_echo.get_reveal_levels())
	visible = true


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		inspect_closed.emit()


func _on_close() -> void:
	visible = false
	inspect_closed.emit()
