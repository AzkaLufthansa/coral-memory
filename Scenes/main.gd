extends Node2D

const PatientScene := preload("res://NPC/patient.tscn")
const RoomScene := preload("res://Scenes/examination_room.tscn")
const OfficeScene := preload("res://UI/office_objects.tscn")
const FileScene := preload("res://UI/patient_file.tscn")
const NotebookScene := preload("res://UI/notebook_panel.tscn")
const MonitorScene := preload("res://UI/facility_monitor.tscn")
const TopicScene := preload("res://UI/topic_panel.tscn")
const EchoInspectScene := preload("res://UI/echo_inspect.tscn")
const DayTransitionScene := preload("res://UI/day_transition.tscn")
const GameOverScene := preload("res://UI/game_over_screen.tscn")

var patient_node: Patient2D
var office: CanvasLayer

# --- PERBAIKAN TIPE DATA ---
# Mengubah PanelContainer menjadi Control agar aman untuk semua jenis Node UI
var file_panel: Control 
var notebook_panel: Control 
var monitor_panel: Control 
var topic_panel: Control 
var echo_inspect: Control
var day_transition: Control
var game_over_screen: Control

var current_patient: PatientData = null
var _report_submitted := false


func _ready() -> void:
	_build_room()
	_build_ui()
	_setup_signals()
	EchoManager.start_game()


func _build_room() -> void:
	var room := RoomScene.instantiate()
	room.name = "Room"
	add_child(room)


func _build_ui() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "UI"
	add_child(ui_layer)

	office = OfficeScene.instantiate()
	ui_layer.add_child(office)

	file_panel = FileScene.instantiate()
	file_panel.visible = false
	ui_layer.add_child(file_panel)

	notebook_panel = NotebookScene.instantiate()
	notebook_panel.visible = false
	ui_layer.add_child(notebook_panel)

	monitor_panel = MonitorScene.instantiate()
	monitor_panel.visible = false
	ui_layer.add_child(monitor_panel)

	topic_panel = TopicScene.instantiate()
	topic_panel.visible = false
	ui_layer.add_child(topic_panel)

	echo_inspect = EchoInspectScene.instantiate()
	echo_inspect.visible = false
	ui_layer.add_child(echo_inspect)

	day_transition = DayTransitionScene.instantiate()
	day_transition.visible = false
	ui_layer.add_child(day_transition)

	game_over_screen = GameOverScene.instantiate()
	game_over_screen.visible = false
	ui_layer.add_child(game_over_screen)


func _setup_signals() -> void:
	EchoManager.day_started.connect(_on_day_started)
	EchoManager.session_started.connect(_on_session_started)
	EchoManager.topic_reacted.connect(_on_topic_reacted)
	EchoManager.echo_burst.connect(_on_echo_burst)
	EchoManager.game_ended.connect(_on_game_ended)

	office.patient_file_pressed.connect(_on_patient_file_pressed)
	office.notebook_pressed.connect(_on_notebook_pressed)
	office.monitor_pressed.connect(_on_monitor_pressed)
	office.call_next_pressed.connect(_on_call_next_pressed)
	office.bell_pressed.connect(_on_bell_pressed)

	file_panel.file_closed.connect(_on_close_panel)
	notebook_panel.notebook_closed.connect(_on_close_panel)
	notebook_panel.report_submitted.connect(_on_report_submitted)
	monitor_panel.monitor_closed.connect(_on_close_panel)
	topic_panel.topic_selected.connect(_on_topic_selected)
	topic_panel.dialogue_finished.connect(_on_dialogue_finished)
	echo_inspect.inspect_closed.connect(_on_close_panel)

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
	patient_node.echo_clicked.connect(_on_echo_clicked)


# --- Office interactions ---

func _on_patient_clicked() -> void:
	if _report_submitted or current_patient == null:
		return
	_close_all_panels()
	topic_panel.open_dialogue(current_patient)


func _on_echo_clicked() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	echo_inspect.show_for(current_patient, patient_node.echo)


func _on_patient_file_pressed() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	file_panel.show_patient(current_patient)


func _on_notebook_pressed() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	notebook_panel.show_notebook()


func _on_monitor_pressed() -> void:
	_close_all_panels()
	monitor_panel.show_monitor()


func _on_topic_selected(topic: Topic.Name) -> void:
	EchoManager.ask_topic(topic)
	topic_panel.show_response(current_patient, topic)


func _on_topic_reacted(patient: PatientData, topic: Topic.Name, relevance: Topic.Relevance) -> void:
	if patient_node and patient_node.current_patient == patient:
		patient_node.on_topic_reacted(relevance)


func _on_dialogue_finished() -> void:
	_close_all_panels()


func _on_report_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule, notes: String) -> void:
	EchoManager.commit_diagnosis(emotion, schedule)
	_report_submitted = true
	office.set_next_enabled(true)


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
	if is_instance_valid(echo_inspect): echo_inspect.visible = false


func _on_echo_burst(patient: PatientData) -> void:
	_close_all_panels()
	game_over_screen.show_burst(patient)


func _on_game_ended(days: int) -> void:
	_close_all_panels()
	game_over_screen.show_ending(days)


func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
