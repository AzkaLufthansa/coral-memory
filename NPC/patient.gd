class_name Patient2D
extends Node2D

@onready var name_label: Label = $NameLabel
@onready var echo: Echo2D = $Echo

var current_patient: PatientData = null


func _draw() -> void:
	# Placeholder pasien: badan sederhana
	var color := Color(0.72, 0.66, 0.6)
	if current_patient and current_patient.is_control_patient:
		color = Color(0.6, 0.7, 0.78)
	var body_points := PackedVector2Array([
		Vector2(-20, -8), Vector2(-14, 44), Vector2(14, 44), Vector2(20, -8),
	])
	draw_colored_polygon(body_points, color)
	# Kepala
	draw_circle(Vector2(0, -24), 16.0, Color(0.9, 0.85, 0.8))


func setup(patient: PatientData) -> void:
	current_patient = patient
	name_label.text = "%s, %d" % [patient.display_name, patient.age]
	if patient.is_control_patient:
		name_label.text += "  [KONTROL]"
	echo.start_session(patient)
	queue_redraw()


func on_topic_reacted(relevance: Topic.Relevance) -> void:
	echo.react(current_patient, relevance)


func update_stability_hint() -> void:
	echo.set_stability_hint(current_patient)
