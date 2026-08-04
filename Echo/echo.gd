class_name Echo2D
extends Node2D

var _fog_time := 0.0
var _fog_color := Color(0.05, 0.05, 0.07, 0.85)
var _elements: Dictionary = {}  # Emotion.Type -> EchoElement
var _patient_emotion: Emotion.Type = Emotion.Type.FEAR
var _fog_scale := 1.0


func _ready() -> void:
	for child in get_children():
		if child is EchoElement:
			_elements[child.emotion] = child


func _process(delta: float) -> void:
	_fog_time += delta
	queue_redraw()


func _draw() -> void:
	# Kabut hitam dasar (State 0) yang berdenyut pelan
	var radius := 34.0 * _fog_scale * (1.0 + sin(_fog_time * 1.2) * 0.04)
	draw_circle(Vector2.ZERO, radius, _fog_color)
	draw_circle(Vector2(6, -4), radius * 0.7, Color(_fog_color.r, _fog_color.g, _fog_color.b, _fog_color.a * 0.6))
	draw_circle(Vector2(-8, 4), radius * 0.6, Color(_fog_color.r, _fog_color.g, _fog_color.b, _fog_color.a * 0.5))


func start_session(patient: PatientData) -> void:
	_patient_emotion = patient.true_emotion
	reset()


func reset() -> void:
	_fog_scale = 1.0
	for element in _elements.values():
		element.reset_reveal()
	queue_redraw()


func react(patient: PatientData, relevance: Topic.Relevance) -> void:
	# Section 15: reaksi Echo berdasarkan relevansi topik terhadap emosi asli.
	var element: EchoElement = _elements.get(_patient_emotion)
	if element == null:
		return
	match relevance:
		Topic.Relevance.PRIMARY:
			element.set_reveal(1.0)
			_fog_scale = 1.0
		Topic.Relevance.SECONDARY:
			element.set_reveal(0.5)
		Topic.Relevance.NEUTRAL:
			_fog_shake()
		Topic.Relevance.DEFLECTIVE:
			_fog_shrink()
	queue_redraw()


func _fog_shake() -> void:
	_fog_scale = 0.97 + randf() * 0.06


func _fog_shrink() -> void:
	_fog_scale = 0.85


func set_stability_hint(patient: PatientData) -> void:
	# Indikator halus kondisi (tanpa angka eksplisit): kabut makin pekat jika tidak stabil.
	var instability := 1.0 - float(patient.stability) / 100.0
	_fog_color = Color(0.05, 0.05, 0.07, 0.7 + instability * 0.3)
