extends Node2D

const PatientScene := preload("res://NPC/patient.tscn")
const RoomScene := preload("res://Scenes/examination_room.tscn")
const HUDScene := preload("res://UI/hud.tscn")
const InfoScene := preload("res://UI/info_panel.tscn")
const DialogueScene := preload("res://UI/dialogue_text.tscn")
const TopicScene := preload("res://UI/topic_panel.tscn")
const DecisionScene := preload("res://UI/decision_panel.tscn")
const GameOverScene := preload("res://UI/game_over_screen.tscn")

var patient_node: Patient2D
var hud: PanelContainer
var info_panel: PanelContainer
var dialogue_text: PanelContainer
var topic_panel: PanelContainer
var decision_panel: PanelContainer
var game_over_screen: Control

var current_patient: PatientData = null
var phase: String = "session"  # session | decision


func _ready() -> void:
	_build_room()
	_build_ui()
	_setup_signals()
	EchoManager.start_game()


func _build_room() -> void:
	# Ruang pemeriksaan (scene terpisah, bisa diganti art final tanpa ubah logika)
	var room := RoomScene.instantiate()
	room.name = "Room"
	add_child(room)


func _build_ui() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "UI"
	add_child(ui_layer)

	hud = HUDScene.instantiate()
	ui_layer.add_child(hud)

	info_panel = InfoScene.instantiate()
	ui_layer.add_child(info_panel)

	dialogue_text = DialogueScene.instantiate()
	dialogue_text.visible = false
	ui_layer.add_child(dialogue_text)

	topic_panel = TopicScene.instantiate()
	topic_panel.visible = false
	ui_layer.add_child(topic_panel)

	decision_panel = DecisionScene.instantiate()
	decision_panel.visible = false
	ui_layer.add_child(decision_panel)

	game_over_screen = GameOverScene.instantiate()
	game_over_screen.visible = false
	ui_layer.add_child(game_over_screen)


func _setup_signals() -> void:
	EchoManager.day_started.connect(_on_day_started)
	EchoManager.session_started.connect(_on_session_started)
	EchoManager.topic_reacted.connect(_on_topic_reacted)
	EchoManager.investigation_finished.connect(_on_investigation_finished)
	EchoManager.echo_burst.connect(_on_echo_burst)
	EchoManager.game_ended.connect(_on_game_ended)
	topic_panel.topic_selected.connect(_on_topic_selected)
	decision_panel.decision_submitted.connect(_on_decision_submitted)
	game_over_screen.restart_requested.connect(_on_restart_requested)


func _on_day_started(day: int) -> void:
	hud.set_day(day)


func _on_session_started(patient: PatientData, session_index: int, total_sessions: int) -> void:
	current_patient = patient
	phase = "session"

	_spawn_patient(patient)
	info_panel.show_patient(patient)
	hud.set_session(session_index, total_sessions)

	dialogue_text.visible = false
	topic_panel.show_topics()
	decision_panel.hide_panel()
	game_over_screen.visible = false


func _spawn_patient(patient: PatientData) -> void:
	if patient_node:
		patient_node.queue_free()
	patient_node = PatientScene.instantiate()
	patient_node.position = Vector2(640, 340)
	add_child(patient_node)
	patient_node.setup(patient)


func _on_topic_selected(topic: Topic.Name) -> void:
	EchoManager.ask_topic(topic)


func _on_topic_reacted(patient: PatientData, topic: Topic.Name, relevance: Topic.Relevance) -> void:
	dialogue_text.show_dialogue(patient, topic)
	patient_node.on_topic_reacted(relevance)
	hud.set_topics_remaining(EchoManager.get_topics_remaining())


func _on_investigation_finished(patient: PatientData) -> void:
	phase = "decision"
	topic_panel.hide_panel()
	decision_panel.show_panel()


func _on_decision_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule) -> void:
	EchoManager.commit_diagnosis(emotion, schedule)


func _on_echo_burst(patient: PatientData) -> void:
	game_over_screen.show_burst(patient)


func _on_game_ended(days: int) -> void:
	game_over_screen.show_ending(days)


func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
