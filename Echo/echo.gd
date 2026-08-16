class_name Echo2D
extends Node2D

signal phase_changed(phase: int)

const FRAME_SIZE := 128
const INITIAL_SHEET := "res://Assets/Echo/Initial.png"
const PHASE2_SHEETS: Dictionary = {
	Emotion.Type.FEAR: "res://Assets/Echo/Fear.png",
}

const INITIAL_FPS := 8.0
const PHASE2_FPS := 8.0

var _patient_emotion: Emotion.Type = Emotion.Type.FEAR
var _phase := 1
var _inspecting := false
var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE

@onready var echo_sprite: AnimatedSprite2D = $EchoSprite


func _ready() -> void:
	_build_sprite_animations()
	_base_position = position
	_base_scale = scale


func _build_sprite_animations() -> void:
	var frames := SpriteFrames.new()

	var initial_tex := load(INITIAL_SHEET) as Texture2D
	if initial_tex:
		frames.add_animation("phase1")
		frames.set_animation_loop("phase1", true)
		frames.set_animation_speed("phase1", INITIAL_FPS)
		for i in range(initial_tex.get_width() / FRAME_SIZE):
			frames.add_frame("phase1", _make_atlas(initial_tex, i, 0))

	for emotion in PHASE2_SHEETS:
		var tex := load(PHASE2_SHEETS[emotion]) as Texture2D
		if tex == null:
			continue
		var anim_name := "phase2_%d" % emotion
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, true)
		frames.set_animation_speed(anim_name, PHASE2_FPS)
		for i in range(tex.get_width() / FRAME_SIZE):
			frames.add_frame(anim_name, _make_atlas(tex, i, 0))

	echo_sprite.sprite_frames = frames


func _make_atlas(tex: Texture2D, col: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(col * FRAME_SIZE, row * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)
	return atlas


func start_session(patient: PatientData) -> void:
	_patient_emotion = patient.true_emotion
	reset()


func reset() -> void:
	_set_phase(1)


func react(patient: PatientData, relevance: Topic.Relevance) -> void:
	# Transformasi ke fase final di-handle main.gd setelah transisi kedip.
	match relevance:
		Topic.Relevance.SECONDARY:
			_pulse(1.15)
		Topic.Relevance.DEFLECTIVE:
			_pulse(0.92)


func transform_to_phase_2() -> void:
	if _phase == 2:
		return
	_set_phase(2)


func _set_phase(phase: int) -> void:
	_phase = phase
	if phase == 2:
		var anim_name := "phase2_%d" % _patient_emotion
		if echo_sprite.sprite_frames and echo_sprite.sprite_frames.has_animation(anim_name):
			echo_sprite.play(anim_name)
		else:
			_phase = 1
			echo_sprite.play("phase1")
	else:
		echo_sprite.play("phase1")
	phase_changed.emit(_phase)


func _pulse(target: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(echo_sprite, "scale", Vector2(target, target), 0.18)
	tween.tween_property(echo_sprite, "scale", Vector2.ONE, 0.35)


func set_stability_hint(patient: PatientData) -> void:
	var instability := 1.0 - float(patient.stability) / 100.0
	echo_sprite.modulate.a = 1.0 - instability * 0.3


func set_inspecting(value: bool) -> void:
	_inspecting = value
	visible = value
	if value:
		position = Vector2(0, 0)
		scale = Vector2(3.5, 3.5)
		z_index = 20
	else:
		position = _base_position
		scale = _base_scale
		z_index = 2


func get_reveal_levels() -> Dictionary:
	return {_patient_emotion: 1.0 if _phase == 2 else 0.0}


func apply_reveal_levels(levels: Dictionary) -> void:
	if levels.get(_patient_emotion, 0.0) >= 1.0:
		_set_phase(2)
	else:
		_set_phase(1)


func get_patient_emotion() -> Emotion.Type:
	return _patient_emotion
