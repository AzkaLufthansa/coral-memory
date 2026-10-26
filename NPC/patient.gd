class_name Patient2D
extends Node2D

signal patient_clicked

const NPC_SHEET := "res://Assets/NPC/Real/NPC Base.png"   # fallback
const PATIENT_DIR := "res://Assets/NPC"                
const FRAME_SIZE := 128
const TALK_FPS := 6.0
const SHOCK_FPS := 6.0
const EMOTION_FPS := 6.0
const ECHO_DELAY := 3.0

# Nama enum Emotion.Type -> nama file. Sesuaikan jika nama enum Anda berbeda.
const EMOTION_FILE_ALIASES := {
	"anger": "angry",
	"sadness": "sad",
	"envy": "envy",
	"shame": "shame",
	"guilt": "guilt",
	"fear": "fear"
}

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
	npc_sprite.animation_finished.connect(_on_npc_animation_finished)
	_build_npc_animations("")  # default sebelum setup() dipanggil
	echo_appear_sfx.stream = SfxUtil.first_available([
		"res://Assets/Audio/SFX gangguan bisikan.mp3",
		"res://Assets/SFX/echo_muncul.mp3",
	])
	play_idle()


# ---------- Sprite & animasi ----------

func _get_sheet_path(sprite_id: String) -> String:
	if sprite_id != "":
		var path := "%s/%s/%s.png" % [PATIENT_DIR, sprite_id, sprite_id]
		if ResourceLoader.exists(path):
			return path
		push_warning("Sprite pasien tidak ditemukan: %s, memakai NPC Base." % path)
	return NPC_SHEET


func _emotion_file_name(type: int) -> String:
	var key: String = Emotion.Type.keys()[type].to_lower()
	return EMOTION_FILE_ALIASES.get(key, key)


func _build_npc_animations(sprite_id: String) -> void:
	var tex := load(_get_sheet_path(sprite_id)) as Texture2D
	if tex == null:
		return

	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

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

	_add_emotion_animations(frames, sprite_id)
	npc_sprite.sprite_frames = frames


func _add_emotion_animations(frames: SpriteFrames, sprite_id: String) -> void:
	if sprite_id == "":
		return
	for type in Emotion.Type.values():
		var file_name := _emotion_file_name(type)
		var path := "%s/%s/%s.png" % [PATIENT_DIR, sprite_id, file_name]
		if not ResourceLoader.exists(path):
			continue
		var etex := load(path) as Texture2D
		if etex == null:
			continue
		var anim := "emotion_" + file_name
		frames.add_animation(anim)
		frames.set_animation_loop(anim, true)
		frames.set_animation_speed(anim, EMOTION_FPS)
		# Jumlah frame dihitung otomatis dari lebar gambar (1 baris, frame 128x128)
		var count := maxi(1, int(etex.get_width() / FRAME_SIZE))
		for i in range(count):
			frames.add_frame(anim, _make_atlas(etex, i, 0))


func _make_atlas(tex: Texture2D, col: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(col * FRAME_SIZE, row * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)
	return atlas


# ---------- Setup ----------

func setup(patient: PatientData) -> void:
	current_patient = patient
	_build_npc_animations(patient.sprite_id)   # <-- ganti sprite sesuai pasien
	play_idle()

	name_label.text = "%s, %d" % [patient.display_name, patient.age]
	if patient.is_control_patient:
		name_label.text += "  [KONTROL]"
	echo.start_session(patient)
	# Delay echo hanya untuk pasien pertama di tiap hari (sesi 1).
	if EchoManager.session_index <= 1:
		_begin_echo_delay()
	else:
		echo.visible = true


func _begin_echo_delay() -> void:
	echo.visible = false
	if is_instance_valid(_echo_timer):
		_echo_timer.queue_free()
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
	tween.tween_property(self, "modulate:a", 0.0, duration)


func on_topic_reacted(relevance: Topic.Relevance) -> void:
	echo.react(current_patient, relevance)


# ---------- Kontrol animasi ----------

func play_talking() -> void:
	_talking = true
	_play_if_exists("talk")


func stop_talking() -> void:
	_talking = false
	play_idle()


func play_idle() -> void:
	_play_if_exists("idle")


func play_shocked() -> void:
	_play_if_exists("shocked")


# Tampilkan ekspresi emosi pasien (angry, envy, fear, guilt, sad, shame)
func play_emotion(type: Emotion.Type) -> void:
	_play_if_exists("emotion_" + _emotion_file_name(type))


func _play_if_exists(anim: String) -> void:
	if npc_sprite.sprite_frames and npc_sprite.sprite_frames.has_animation(anim):
		npc_sprite.play(anim)


func transform_echo() -> void:
	if current_patient:
		current_patient.echo_transformed = true
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
