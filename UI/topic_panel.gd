extends PanelContainer

signal topic_selected(topic: Topic.Name)
signal dialogue_finished

@onready var title_label: Label = %TitleLabel
@onready var response_label: Label = %ResponseLabel
@onready var grid: GridContainer = %Grid
@onready var finish_button: Button = %FinishButton
@onready var remaining_label: Label = %RemainingLabel

var _buttons: Dictionary = {}  # Topic.Name -> Button


func _ready() -> void:
	_build_buttons()
	finish_button.pressed.connect(func() -> void: dialogue_finished.emit())


func _build_buttons() -> void:
	for topic in Topic.ALL_TOPICS:
		var button := Button.new()
		button.text = Topic.display_name(topic)
		button.custom_minimum_size = Vector2(150, 40)
		button.pressed.connect(_on_topic_pressed.bind(topic))
		grid.add_child(button)
		_buttons[topic] = button


func open_dialogue(patient: PatientData) -> void:
	title_label.text = "Pilih pertanyaan untuk %s" % patient.display_name
	response_label.text = ""
	remaining_label.text = "Pertanyaan tersisa: %d" % EchoManager.get_topics_remaining()
	var has_topics := EchoManager.get_topics_remaining() > 0
	for topic in _buttons:
		var used := patient.topics_used.has(topic)
		_buttons[topic].disabled = used
		_buttons[topic].visible = not used
		_buttons[topic].modulate = Color(1, 1, 1, 0.4) if used else Color.WHITE
	finish_button.text = "Cukup" if has_topics else "Kembali"
	visible = true


func show_response(patient: PatientData, topic: Topic.Name) -> void:
	response_label.text = "%s: %s" % [patient.display_name, patient.get_dialog(topic)]
	remaining_label.text = "Pertanyaan tersisa: %d" % EchoManager.get_topics_remaining()


func close_dialogue() -> void:
	visible = false


func _on_topic_pressed(topic: Topic.Name) -> void:
	topic_selected.emit(topic)
