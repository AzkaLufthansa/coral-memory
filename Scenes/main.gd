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

var patient_node: Patient2D
var office: CanvasLayer

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

var current_patient: PatientData = null
var _report_submitted := false

var _sfx_footsteps: AudioStreamPlayer
var _sfx_door: AudioStreamPlayer


func _ready() -> void:
	_build_room()
	_build_ui()
	_build_sfx()
	_setup_signals()
	EchoManager.start_game()


func _build_room() -> void:
	var room := RoomScene.instantiate()
	room.name = "Room"
	add_child(room)


func _build_ui() -> void:
	# Layer 1: objek kantor (meja, tombol-tombol) + overlay gelap.
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "UI"
	add_child(ui_layer)

	ui_dim = ColorRect.new()
	ui_dim.color = Color(0, 0, 0, 0.6)
	ui_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_dim.visible = false
	ui_layer.add_child(ui_dim)

	office = OfficeScene.instantiate()
	ui_layer.add_child(office)

	# Layer 2: panel interaktif (monitor, buku, transisi, dst) agar selalu
	# tampil di atas objek kantor.
	var panels_layer := CanvasLayer.new()
	panels_layer.name = "Panels"
	panels_layer.layer = 2
	add_child(panels_layer)

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


func _build_sfx() -> void:
	_sfx_footsteps = AudioStreamPlayer.new()
	_sfx_footsteps.stream = SfxUtil.first_available([
		"res://Assets/Audio/SFX langkah kaki 1x bunyi.mp3",
		"res://Assets/SFX/langkah_kaki.mp3",
	])
	add_child(_sfx_footsteps)

	_sfx_door = AudioStreamPlayer.new()
	_sfx_door.stream = SfxUtil.first_available([
		"res://Assets/Audio/SFX buka tutup kunci pintu.mp3",
		"res://Assets/SFX/pintu_terbuka.mp3",
	])
	add_child(_sfx_door)


func _setup_signals() -> void:
	EchoManager.day_started.connect(_on_day_started)
	EchoManager.session_started.connect(_on_session_started)
	EchoManager.topic_reacted.connect(_on_topic_reacted)
	EchoManager.end_of_day_finished.connect(_on_end_of_day_finished)
	EchoManager.echo_burst.connect(_on_echo_burst)
	EchoManager.game_ended.connect(_on_game_ended)

	office.patient_file_pressed.connect(_on_patient_file_pressed)
	office.notebook_pressed.connect(_on_notebook_pressed)
	office.monitor_pressed.connect(_on_monitor_pressed)
	office.call_next_pressed.connect(_on_call_next_pressed)
	office.bell_pressed.connect(_on_bell_pressed)
	office.guidebook_pressed.connect(_on_guidebook_pressed)
	var guide_book: Control = office.get("guide_book") as Control
	if guide_book:
		guide_book.closed.connect(_on_guide_book_closed)

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


func _on_session_started(patient: PatientData, session_index: int, total_sessions: int) -> void:
	current_patient = patient
	_report_submitted = false
	_spawn_patient(patient)
	_close_all_panels()
	office.show_office()
	office.set_next_enabled(false)


func _spawn_patient(patient: PatientData) -> void:
	if patient_node:
		patient_node.queue_free()
	patient_node = PatientScene.instantiate()
	patient_node.position = Vector2(576, 224)
	patient_node.z_index = 1
	add_child(patient_node)
	patient_node.setup(patient)
	patient_node.patient_clicked.connect(_on_patient_clicked)


# --- Office interactions ---

func _on_patient_clicked() -> void:
	if _report_submitted or current_patient == null:
		return
	_close_all_panels()
	topic_panel.open_dialogue(current_patient)


func _on_patient_file_pressed() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	ui_dim.visible = true
	file_panel.show_patient(current_patient)


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


func _on_topic_selected(topic: Topic.Name) -> void:
	if patient_node:
		patient_node.play_talking()
	EchoManager.ask_topic(topic)
	topic_panel.show_response(current_patient, topic)


func _on_topic_reacted(patient: PatientData, topic: Topic.Name, relevance: Topic.Relevance) -> void:
	if patient_node == null or patient_node.current_patient != patient:
		return
	if relevance == Topic.Relevance.PRIMARY:
		patient_node.play_shocked()
		await transform_flash.play()
		if is_instance_valid(patient_node):
			patient_node.transform_echo()
	else:
		patient_node.on_topic_reacted(relevance)


func _on_dialogue_finished() -> void:
	_close_all_panels()


func _on_report_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule, notes: String) -> void:
	if _report_submitted:
		return
	EchoManager.commit_diagnosis(emotion, schedule)
	_report_submitted = true
	office.set_next_enabled(true)


func _on_monitor_decision_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule) -> void:
	_on_report_submitted(emotion, schedule, "")


func _on_call_next_pressed() -> void:
	EchoManager.call_next_patient()


func _on_bell_pressed() -> void:
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
	if _sfx_footsteps and _sfx_footsteps.stream:
		_sfx_footsteps.play()
	await get_tree().create_timer(1.0).timeout
	if _sfx_door and _sfx_door.stream:
		_sfx_door.play()
	await get_tree().create_timer(1.2).timeout
	EchoManager.advance_day()


func _on_echo_burst(patient: PatientData) -> void:
	_close_all_panels()
	game_over_screen.show_burst(patient)


func _on_game_ended(days: int) -> void:
	_close_all_panels()
	game_over_screen.show_ending(days)


func _on_restart_requested() -> void:
	Echo2D.reset_revealed()
	get_tree().reload_current_scene()
