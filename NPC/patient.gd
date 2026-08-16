class_name Patient2D
extends Node2D

signal patient_clicked

const NPC_SHEET := "res://Assets/NPC/Real/NPC Base.png"
const FRAME_SIZE := 128
const TALK_FPS := 6.0
const SHOCK_FPS := 6.0
const ECHO_DELAY := 3.0

@onready var name_label: Label = $NameLabel
@onready var echo: Echo2D = $Echo
@onready var click_area: Area2D = $ClickArea
@onready var npc_sprite: AnimatedSprite2D = $NpcSprite
@onready var echo_appear_sfx: AudioStreamPlayer = $EchoAppear

var current_patient: PatientData = null
var _talking := false
var _echo_timer: Timer


func _ready() -> void:
	click_area.input_event.connect(_on_patient_clicked)
	_build_npc_animations()
	npc_sprite.animation_finished.connect(_on_npc_animation_finished)
	echo_appear_sfx.stream = SfxUtil.first_available([
		"res://Assets/Audio/SFX gangguan bisikan.mp3",
		"res://Assets/SFX/echo_muncul.mp3",
	])
	play_idle()


func _build_npc_animations() -> void:
	var tex := load(NPC_SHEET) as Texture2D
	if tex == null:
		return
	var frames := SpriteFrames.new()

	frames.add_animation("idle")
	frames.set_animation_loop("idle", false)
	frames.set_animation_speed("idle", 1.0)
	frames.add_frame("idle", _make_atlas(tex, 0, 0))

	frames.add_animation("talk")
	frames.set_animation_loop("talk", true)
	frames.set_animation_speed("talk", TALK_FPS)
	for i in range(5):
		frames.add_frame("talk", _make_atlas(tex, i, 0))

	frames.add_animation("shocked")
	frames.set_animation_loop("shocked", false)
	frames.set_animation_speed("shocked", SHOCK_FPS)
	for i in range(2):
		frames.add_frame("shocked", _make_atlas(tex, i, 1))

	npc_sprite.sprite_frames = frames


func _make_atlas(tex: Texture2D, col: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(col * FRAME_SIZE, row * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)
	return atlas


func setup(patient: PatientData) -> void:
	current_patient = patient
	name_label.text = "%s, %d" % [patient.display_name, patient.age]
	if patient.is_control_patient:
		name_label.text += "  [KONTROL]"
	echo.start_session(patient)
	_begin_echo_delay()


func _begin_echo_delay() -> void:
	echo.visible = false
	_echo_timer = Timer.new()
	_echo_timer.one_shot = true
	_echo_timer.wait_time = ECHO_DELAY
	_echo_timer.timeout.connect(_show_echo)
	add_child(_echo_timer)
	_echo_timer.start()


func _show_echo() -> void:
	if not is_instance_valid(echo):
		return
	echo.visible = true
	if echo_appear_sfx and echo_appear_sfx.stream:
		echo_appear_sfx.play()


func fade_out(duration := 1.2) -> void:
	var tween := create_tween()
	tween.tween_property(npc_sprite, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(name_label, "modulate:a", 0.0, duration)


func on_topic_reacted(relevance: Topic.Relevance) -> void:
	echo.react(current_patient, relevance)


func play_talking() -> void:
	_talking = true
	if npc_sprite.sprite_frames and npc_sprite.sprite_frames.has_animation("talk"):
		npc_sprite.play("talk")


func stop_talking() -> void:
	_talking = false
	play_idle()


func play_idle() -> void:
	if npc_sprite.sprite_frames and npc_sprite.sprite_frames.has_animation("idle"):
		npc_sprite.play("idle")


func play_shocked() -> void:
	if npc_sprite.sprite_frames and npc_sprite.sprite_frames.has_animation("shocked"):
		npc_sprite.play("shocked")


func transform_echo() -> void:
	echo.transform_to_phase_2()


func _on_npc_animation_finished() -> void:
	if npc_sprite.animation == "shocked":
		if _talking:
			play_talking()
		else:
			play_idle()


func update_stability_hint() -> void:
	echo.set_stability_hint(current_patient)


func _on_patient_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		patient_clicked.emit()
