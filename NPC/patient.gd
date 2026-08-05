class_name Patient2D
extends Node2D

signal patient_clicked
signal echo_clicked

@onready var name_label: Label = $NameLabel
@onready var echo: Echo2D = $Echo
@onready var click_area: Area2D = $ClickArea

var current_patient: PatientData = null


func _ready() -> void:
	click_area.input_event.connect(_on_patient_clicked)
	echo.echo_clicked.connect(func() -> void: echo_clicked.emit())


func setup(patient: PatientData) -> void:
	current_patient = patient
	name_label.text = "%s, %d" % [patient.display_name, patient.age]
	if patient.is_control_patient:
		name_label.text += "  [KONTROL]"
	echo.start_session(patient)


func on_topic_reacted(relevance: Topic.Relevance) -> void:
	echo.react(current_patient, relevance)


func update_stability_hint() -> void:
	echo.set_stability_hint(current_patient)


func inspect_echo() -> void:
	echo.set_inspecting(true)


func end_echo_inspect() -> void:
	echo.set_inspecting(false)


func _on_patient_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		patient_clicked.emit()
