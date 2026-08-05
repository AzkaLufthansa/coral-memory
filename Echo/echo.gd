class_name Echo2D
extends Node2D

signal echo_clicked

const AURA_FRAMES_DIR := "res://Assets/Echo/Aura/Sprites/"
const AURA_FRAME_COUNT := 25
const AURA_FPS := 12.0

var _fog_scale := 1.0
var _elements: Dictionary = {}  # Emotion.Type -> EchoElement
var _patient_emotion: Emotion.Type = Emotion.Type.FEAR
var _inspecting := false
var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE

@onready var aura: AnimatedSprite2D = $Aura
@onready var click_area: Area2D = $ClickArea


func _ready() -> void:
	for child in get_children():
		if child is EchoElement:
			_elements[child.emotion] = child
	_build_aura_animation()
	click_area.input_event.connect(_on_clicked)
	_base_position = position
	_base_scale = scale


func _build_aura_animation() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", AURA_FPS)
	for i in range(1, AURA_FRAME_COUNT + 1):
		var frame_texture := load(AURA_FRAMES_DIR + "%04d.png" % i) as Texture2D
		if frame_texture:
			frames.add_frame("idle", frame_texture)
	if frames.get_frame_count("idle") > 0:
		aura.sprite_frames = frames
		aura.play("idle")


func start_session(patient: PatientData) -> void:
	_patient_emotion = patient.true_emotion
	reset()


func reset() -> void:
	_fog_scale = 1.0
	for element in _elements.values():
		element.reset_reveal()


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
			pass
		Topic.Relevance.DEFLECTIVE:
			_fog_scale = 0.85


func set_stability_hint(patient: PatientData) -> void:
	# Indikator halus kondisi (tanpa angka eksplisit): aura makin pekat jika tidak stabil.
	var instability := 1.0 - float(patient.stability) / 100.0
	aura.modulate.a = 1.0 - instability * 0.3


func set_inspecting(value: bool) -> void:
	_inspecting = value
	visible = value
	if value:
		# Perbesar & tampilkan di tengah layar saat diperiksa
		position = Vector2(0, 0)
		scale = Vector2(3.5, 3.5)
		z_index = 20
	else:
		position = _base_position
		scale = _base_scale
		z_index = 2


func _on_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		echo_clicked.emit()


func get_reveal_levels() -> Dictionary:
	var out := {}
	for emotion in _elements:
		out[emotion] = _elements[emotion].reveal_level
	return out


func apply_reveal_levels(levels: Dictionary) -> void:
	for emotion in levels:
		var element: EchoElement = _elements.get(emotion)
		if element:
			element.set_reveal(levels[emotion])


func get_patient_emotion() -> Emotion.Type:
	return _patient_emotion
