extends Node2D

const PatientScene := preload("res://NPC/patient.tscn")
const RoomScene := preload("res://Scenes/examination_room.tscn")
const BookScene := preload("res://UI/examination_book.tscn")
const MonitorScene := preload("res://UI/patient_monitor.tscn")
const TopicScene := preload("res://UI/topic_panel.tscn")
const EchoInspectScene := preload("res://UI/echo_inspect.tscn")
const DayTransitionScene := preload("res://UI/day_transition.tscn")
const GameOverScene := preload("res://UI/game_over_screen.tscn")

var room: Node2D
var patient_node: Patient2D
var book: Control
var monitor: Control
var topic_panel: PanelContainer
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
	room = RoomScene.instantiate()
	room.name = "Room"
	add_child(room)


func _build_ui() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "UI"
	add_child(ui_layer)

	book = BookScene.instantiate()
	book.visible = false
	ui_layer.add_child(book)

	monitor = MonitorScene.instantiate()
	monitor.visible = false
	ui_layer.add_child(monitor)

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

	room.bell_clicked.connect(_on_bell_clicked)
	room.book_clicked.connect(_on_book_clicked)
	room.monitor_clicked.connect(_on_monitor_clicked)

	book.book_closed.connect(_on_close_panel)
	book.report_submitted.connect(_on_report_submitted)
	monitor.monitor_closed.connect(_on_close_panel)
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


func _spawn_patient(patient: PatientData) -> void:
	if patient_node:
		patient_node.queue_free()
	patient_node = PatientScene.instantiate()
	patient_node.position = Vector2(576, 324)
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


func _on_bell_clicked() -> void:
	# Bel: panggil pasien berikutnya (hanya aktif setelah submit)
	if _report_submitted:
		EchoManager.call_next_patient()


func _on_book_clicked() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	book.show_book()


func _on_monitor_clicked() -> void:
	if current_patient == null:
		return
	_close_all_panels()
	monitor.show_monitor(current_patient)


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


func _on_close_panel() -> void:
	book.hide_book()
	monitor.hide_monitor()
	topic_panel.close_dialogue()
	echo_inspect.visible = false


func _close_all_panels() -> void:
	book.hide_book()
	monitor.hide_monitor()
	topic_panel.close_dialogue()
	echo_inspect.visible = false


# --- Game over / ending ---

func _on_echo_burst(patient: PatientData) -> void:
	_close_all_panels()
	game_over_screen.show_burst(patient)


func _on_game_ended(days: int) -> void:
	_close_all_panels()
	game_over_screen.show_ending(days)


func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
