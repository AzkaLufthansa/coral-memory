extends CanvasLayer

signal patient_file_pressed
signal notebook_pressed
signal monitor_pressed
signal bell_pressed
signal call_next_pressed

@onready var bell_button: Button = %BellButton
@onready var call_next_button: Button = %CallNextButton


func _ready() -> void:
	%PatientFileButton.pressed.connect(func() -> void: patient_file_pressed.emit())
	%NotebookButton.pressed.connect(func() -> void: notebook_pressed.emit())
	%MonitorButton.pressed.connect(func() -> void: monitor_pressed.emit())
	bell_button.pressed.connect(func() -> void: bell_pressed.emit())
	call_next_button.pressed.connect(func() -> void: call_next_pressed.emit())
	set_next_enabled(false)


func show_office() -> void:
	visible = true


func set_next_enabled(enabled: bool) -> void:
	call_next_button.visible = enabled
	call_next_button.disabled = not enabled
	bell_button.visible = not enabled
