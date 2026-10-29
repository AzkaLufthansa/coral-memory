extends Node2D

const PatientScene := preload("res://NPC/patient.tscn")
const RoomScene := preload("res://Scenes/examination_room.tscn")
const OfficeScene := preload("res://UI/office_objects.tscn")
const FileScene := preload("res://UI/patient_file.tscn")
const NotebookScene := preload("res://UI/notebook_panel.tscn")
const MonitorScene := preload("res://UI/facility_monitor.tscn")
const TopicScene := preload("res://UI/topic_panel.tscn")
const DayTransitionScene := preload("res://UI/day_transition.tscn")
const TransformFlashScene := preload("res://UI/transform_flash.tscn")
const GameOverScene := preload("res://UI/game_over_screen.tscn")
const TutorialGuide := preload("res://UI/tutorial_guide.gd")

# Tutorial highlight bertahap (pasien pertama Day 1). Tiap langkah maju saat
# event-nya terjadi. Soft hint: tidak memblokir klik lain.
const TUT_STEP_EVENTS := ["file_opened", "interview", "topics_done", "diagnosis", "next"]
const TUT_STEP_TEXTS := [
	"Mulai dengan membaca berkas pasien (klik berkas di kiri bawah).",
	"Klik pasien di meja untuk memulai wawancara.",
	"Pilih topik pertanyaan (maks 3). Perhatikan wujud Echo berubah.",
	"Buka berkas lalu tab Submit: tentukan emosi dominan & jadwal kontrol.",
	"Klik lonceng di kanan bawah untuk memanggil pasien berikutnya.",
]
const SPRITE_POOL_CAT := PatientFactory.CAT_SPRITES
const SPRITE_POOL_FEMALE := PatientFactory.FEMALE_SPRITES
const SPRITE_POOL_MALE := PatientFactory.MALE_SPRITES
const SPRITE_POOL := [
	"Pasien1", "Pasien3", "Pasien6", "Pasien7",
	"Pasien8", "Pasien9", "Pasien10", "Pasien11",
]

# Ukuran keseluruhan pasien relatif terhadap nilai aslinya.
const PATIENT_SCALE := 1.4
# Posisi Y root pasien. Dasar sprite (local y=304) dipetakan ke y ≈ 528
# (garis "duduk" di meja) setelah dikali PATIENT_SCALE.
const PATIENT_BASE_Y := 528.0 - PATIENT_SCALE * 304.0

var patient_node: Patient2D
var office: CanvasLayer
var _spawn_count := 0
# --- PERBAIKAN TIPE DATA ---
# Mengubah PanelContainer menjadi Control agar aman untuk semua jenis Node UI
var file_panel: Control 
var notebook_panel: Control 
var monitor_panel: Control 
var topic_panel: Control 
var day_transition: Control
var transform_flash: Control
var game_over_screen: Control
var ui_dim: ColorRect

var pause_menu: CanvasLayer

var current_patient: PatientData = null
var _report_submitted := false

var tutorial
var _tut_active := false
var _tut_step := -1
var _tut_pending := false
var _tut_done := false

var _bgm: AudioStreamPlayer
var _bgm_pause: AudioStreamPlayer
var _bgm_transition: AudioStreamPlayer
var _bgm_tense: AudioStreamPlayer
var _bgm_tense_pause: AudioStreamPlayer
var _bgm_tense_transition: AudioStreamPlayer
var _sfx_footsteps: AudioStreamPlayer
var _sfx_door: AudioStreamPlayer


func _ready() -> void:
	_build_room()
	_build_ui()
	_build_bgm()
	_build_sfx()
	_setup_signals()
	EchoManager.start_game()


func _build_room() -> void:
	var room := RoomScene.instantiate()
	room.name = "Room"
	add_child(room)


func _build_ui() -> void:
	# Layer 1: objek kantor (meja, tombol-tombol) + overlay gelap.
	var ui_layer := $UILayer
	ui_dim = $UILayer/UIDim

	office = OfficeScene.instantiate()
	ui_layer.add_child(office)

	# Layer 2: panel interaktif (monitor, buku, transisi, dst) agar selalu
	# tampil di atas objek kantor.
	var panels_layer := $Panels

	file_panel = FileScene.instantiate()
	file_panel.visible = false
	panels_layer.add_child(file_panel)

	notebook_panel = NotebookScene.instantiate()
	notebook_panel.visible = false
	panels_layer.add_child(notebook_panel)

	monitor_panel = MonitorScene.instantiate()
	monitor_panel.visible = false
	panels_layer.add_child(monitor_panel)

	topic_panel = TopicScene.instantiate()
	topic_panel.visible = false
	panels_layer.add_child(topic_panel)

	day_transition = DayTransitionScene.instantiate()
	day_transition.visible = false
	panels_layer.add_child(day_transition)

	transform_flash = TransformFlashScene.instantiate()
	transform_flash.visible = false
	panels_layer.add_child(transform_flash)

	game_over_screen = GameOverScene.instantiate()
	game_over_screen.visible = false
	panels_layer.add_child(game_over_screen)

	# Layer 3: UI tutorial (petunjuk) di atas objek kantor & panel.
	var tutorial_layer := CanvasLayer.new()
	tutorial_layer.layer = 3
	add_child(tutorial_layer)
	tutorial = TutorialGuide.new()
	tutorial_layer.add_child(tutorial)

	# Layer 999: pause menu
	var pause_menu = $PauseMenu
	pause_menu.game_paused.connect(_on_game_paused)
	pause_menu.game_resumed.connect(_on_game_resumed)
	pause_menu.game_exited.connect(_on_game_exited)

func _on_game_paused() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music_Paused"), false)
	
func _on_game_resumed() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music_Paused"), true)

func _on_game_exited() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music_Paused"), true)
	_bgm.stop()
	_bgm_pause.stop()

func _build_bgm() -> void:
	_bgm = $GameBGM
	_bgm_pause = $GameBGMPause
	_bgm_transition = $GameBGMTransition
	_bgm_tense = $TenseBGM
	_bgm_tense_pause = $TenseBGMPause
	_bgm_tense_transition = $TenseBGMTransition

func _build_sfx() -> void:
	_sfx_footsteps = $EnterSFX
	_sfx_door = $EnterSFX2


func _setup_signals() -> void:
	EchoManager.day_started.connect(_on_day_started)
	EchoManager.session_started.connect(_on_session_started)
	EchoManager.topic_reacted.connect(_on_topic_reacted)
	EchoManager.end_of_day_finished.connect(_on_end_of_day_finished)
	EchoManager.echo_burst.connect(_on_echo_burst)
	EchoManager.game_ended.connect(_on_game_ended)
	EchoManager.game_failed.connect(_on_game_failed)
	EchoManager.investigation_finished.connect(_on_investigation_finished)

	office.patient_file_pressed.connect(_on_patient_file_pressed)
	office.notebook_pressed.connect(_on_notebook_pressed)
	office.monitor_pressed.connect(_on_monitor_pressed)
	office.call_next_pressed.connect(_on_call_next_pressed)
	office.bell_pressed.connect(_on_bell_pressed)
	office.guidebook_pressed.connect(_on_guidebook_pressed)
	var guide_book: Control = office.get("guide_book") as Control
	if guide_book:
		guide_book.closed.connect(_on_guide_book_closed)
		guide_book.visibility_changed.connect(_on_guide_book_visibility_changed)

	file_panel.file_closed.connect(_on_close_panel)
	file_panel.decision_submitted.connect(_on_monitor_decision_submitted)
	notebook_panel.notebook_closed.connect(_on_close_panel)
	notebook_panel.report_submitted.connect(_on_report_submitted)
	monitor_panel.monitor_closed.connect(_on_close_panel)
	topic_panel.topic_selected.connect(_on_topic_selected)
	topic_panel.dialogue_finished.connect(_on_dialogue_finished)

	game_over_screen.restart_requested.connect(_on_restart_requested)


# --- Session lifecycle ---

func _on_day_started(day: int) -> void:
	day_transition.show_day(day)
	if _bgm and _bgm_pause:
		AudioFade.fade_in(_bgm, 4)
		_bgm_pause.play()


func _on_session_started(patient: PatientData, session_index: int, total_sessions: int) -> void:
	current_patient = patient
	_report_submitted = false
	_spawn_patient(patient)
	_close_all_panels()
	office.show_office()
	office.set_next_enabled(false)
	if EchoManager.day == 1 and EchoManager.session_index == 1 and not _tut_done:
		_tut_auto_open_guidebook()

func _spawn_patient(patient: PatientData) -> void:
	if patient_node:
		patient_node.queue_free()

	# Pastikan sprite sesuai mapping tipe NPC:
	# - Pasien3 khusus kategori cat (NPC-H)
	# - Pasien6 & Pasien8 khusus kategori female (NPC-A, NPC-E)
	# - Pasien1, 7, 9, 10, 11 khusus kategori male (NPC-B, C, D, F, G)
	var expected_sprite := PatientFactory.get_sprite_for_npc(patient.base_npc_id)
	if patient.sprite_id == "":
		patient.sprite_id = expected_sprite
	elif PatientFactory.is_cat_npc(patient.base_npc_id) and patient.sprite_id != "Pasien3":
		patient.sprite_id = "Pasien3"
	elif not PatientFactory.is_cat_npc(patient.base_npc_id) and patient.sprite_id == "Pasien3":
		patient.sprite_id = expected_sprite
	elif PatientFactory.is_female_npc(patient.base_npc_id) and not SPRITE_POOL_FEMALE.has(patient.sprite_id):
		patient.sprite_id = expected_sprite
	elif PatientFactory.is_male_npc(patient.base_npc_id) and not SPRITE_POOL_MALE.has(patient.sprite_id):
		patient.sprite_id = expected_sprite
	
	_spawn_count += 1
	print("Pasien ke-%d | Base: %s | Sprite: %s | Emotion: %s (%s)" % [
		_spawn_count, patient.base_npc_id, patient.sprite_id,
		Emotion.display_name(patient.true_emotion), Emotion.echo_name(patient.true_emotion)
	])

	patient_node = PatientScene.instantiate()
	# Skala keseluruhan pasien (NPC + echo + label + hitbox) agar proporsional
	# terhadap meja. Ubah PATIENT_SCALE untuk memperbesar/memperkecil.
	patient_node.scale = Vector2(PATIENT_SCALE, PATIENT_SCALE)
	# Posisi Y digeser naik supaya dasar pasien tetap "duduk" di garis meja
	# walau skalanya diperbesar (semua anak ikut membesar dari titik origin).
	patient_node.position = Vector2(576, PATIENT_BASE_Y)
	patient_node.z_index = 1
	add_child(patient_node)
	patient_node.setup(patient)
	patient_node.patient_clicked.connect(_on_patient_clicked)

func _next_sprite_id(base_npc_id: String = "") -> String:
	return PatientFactory.get_sprite_for_npc(base_npc_id)

# --- Office interactions ---

func _on_patient_clicked() -> void:
	if _report_submitted or current_patient == null:
		return
	_close_all_panels()
	topic_panel.open_dialogue(current_patient)
	_tut_notify("interview")


func _on_patient_file_pressed() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	ui_dim.visible = true
	file_panel.show_patient(current_patient)
	_tut_notify("file_opened")


func _on_notebook_pressed() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	notebook_panel.show_notebook()


func _on_monitor_pressed() -> void:
	_close_all_panels()
	monitor_panel.show_monitor()


func _on_guidebook_pressed() -> void:
	ui_dim.visible = true


func _on_guide_book_closed() -> void:
	ui_dim.visible = false


func _on_guide_book_visibility_changed() -> void:
	# Bisa ditutup lewat tombol close ATAU lewat _close_all_panels; dua-duanya
	# memicu visibility_changed. Mulai tutorial begitu Guidebook tersembunyi.
	if not _tut_pending or office == null:
		return
	var guide_book: Control = office.get("guide_book") as Control
	if guide_book and not guide_book.visible:
		ui_dim.visible = false
		_tut_begin()


# --- Tutorial (highlight bertahap, pasien pertama Day 1) ---

func _tut_auto_open_guidebook() -> void:
	_tut_pending = true
	if office == null:
		_tut_begin()
		return
	var guide_book: Control = office.get("guide_book") as Control
	if guide_book:
		ui_dim.visible = true
		guide_book.show()
	else:
		_tut_begin()


func _tut_begin() -> void:
	_tut_pending = false
	_tut_active = true
	_tut_step = 0
	_tut_show_step()


func _tut_show_step() -> void:
	if not _tut_active or tutorial == null:
		return
	if _tut_step < 0 or _tut_step >= TUT_STEP_TEXTS.size():
		_tut_finish()
		return
	tutorial.show_hint(TUT_STEP_TEXTS[_tut_step], _tut_target(_tut_step))


func _tut_notify(event: String) -> void:
	if not _tut_active:
		return
	var idx := TUT_STEP_EVENTS.find(event)
	if idx < 0:
		return
	# Lonceng hanya menutup tutorial di langkah terakhirnya, supaya klik
	# lonceng yang tidak sengaja di awal tidak langsung mengakhiri tutorial.
	if event == "next" and _tut_step != TUT_STEP_EVENTS.size() - 1:
		return
	if idx < _tut_step:
		return
	_tut_step = idx + 1
	_tut_show_step()


func _tut_finish() -> void:
	_tut_active = false
	_tut_pending = false
	_tut_done = true
	if tutorial:
		tutorial.hide_hint()


func _tut_target(step: int) -> Node:
	if office == null:
		return null
	match step:
		0, 3:
			return office.get_node_or_null("PatientFileButton")
		1:
			return patient_node
		2:
			return topic_panel
		4:
			return office.get_node_or_null("CallNextButton")
	return null


func _on_topic_selected(topic: Topic.Name) -> void:
	if patient_node:
		patient_node.play_talking()
	EchoManager.ask_topic(topic)
	topic_panel.show_response(current_patient, topic)
	if current_patient != null and current_patient.is_diagnosed:
		office.set_next_enabled(true)


func _on_topic_reacted(patient: PatientData, topic: Topic.Name, relevance: Topic.Relevance) -> void:
	if patient_node == null or patient_node.current_patient != patient:
		return
	if relevance == Topic.Relevance.PRIMARY:
		patient.echo_transformed = true
		patient_node.play_shocked()
		await transform_flash.play()
		if is_instance_valid(patient_node):
			patient_node.transform_echo()
	else:
		patient_node.on_topic_reacted(relevance)


func _on_dialogue_finished() -> void:
	_close_all_panels()
	if current_patient != null and current_patient.is_diagnosed:
		office.set_next_enabled(true)


func _on_investigation_finished(_patient: PatientData) -> void:
	_tut_notify("topics_done")


func _on_report_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule, notes: String) -> void:
	if _report_submitted:
		return
	EchoManager.commit_diagnosis(emotion, schedule)
	_report_submitted = true
	office.set_next_enabled(true)
	_tut_notify("diagnosis")


func _on_monitor_decision_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule) -> void:
	_on_report_submitted(emotion, schedule, "")


func _on_call_next_pressed() -> void:
	_tut_notify("next")
	EchoManager.call_next_patient()


func _on_bell_pressed() -> void:
	_tut_notify("next")
	EchoManager.call_next_patient()


func _on_close_panel() -> void:
	_close_all_panels()


func _close_all_panels() -> void:
	if is_instance_valid(file_panel): file_panel.visible = false
	if is_instance_valid(notebook_panel): notebook_panel.visible = false
	if is_instance_valid(monitor_panel): monitor_panel.visible = false
	if is_instance_valid(topic_panel) and topic_panel.has_method("close_dialogue"):
		topic_panel.close_dialogue()
	if is_instance_valid(patient_node): patient_node.stop_talking()
	if is_instance_valid(ui_dim): ui_dim.visible = false
	var guide_book: Control = office.get("guide_book") as Control if office else null
	if guide_book and guide_book.visible:
		guide_book.visible = false


func _on_end_of_day_finished(day: int) -> void:
	_close_all_panels()
	if is_instance_valid(patient_node):
		patient_node.fade_out(1.2)
	if _bgm and _bgm.stream:
		AudioFade.fade_out(_bgm)
	if _sfx_footsteps and _sfx_footsteps.stream:
		_sfx_footsteps.play()
	await get_tree().create_timer(1.0).timeout
	if _sfx_door and _sfx_door.stream:
		_sfx_door.play()
	await get_tree().create_timer(1.2).timeout
	EchoManager.advance_day()


func _stop_all_bgm() -> void:
	var players: Array = [
		_bgm, _bgm_pause, _bgm_transition,
		_bgm_tense, _bgm_tense_pause, _bgm_tense_transition
	]
	for player in players:
		if is_instance_valid(player) and player is AudioStreamPlayer and player.playing:
			player.stop()


func _on_echo_burst(patient: PatientData) -> void:
	_close_all_panels()
	_stop_all_bgm()
	game_over_screen.show_burst(patient)


func _on_game_ended(days: int) -> void:
	_close_all_panels()
	_stop_all_bgm()
	game_over_screen.show_ending(days)


func _on_game_failed(detail: String) -> void:
	_close_all_panels()
	_stop_all_bgm()
	game_over_screen.show_game_over(detail)


func _on_restart_requested() -> void:
	Echo2D.reset_revealed()
	get_tree().reload_current_scene()
