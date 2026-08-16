extends Control

signal topic_selected(topic: Topic.Name)
signal dialogue_finished

const TYPE_INTERVAL := 0.03
const TYPE_START_DELAY := 0.5
const OPEN_TEXT := "..."
const DIALOG_PANEL_DEFAULT := 614.0
const DIALOG_PANEL_EXPANDED := 1166.0
const DOWN_ARROW_TEXTURE := "res://Assets/Textures/Down.png"

@onready var dialog_panel: ColorRect = $DialogPanel
@onready var dialog_label: Label = $DialogPanel/DialogLabel
@onready var topic_choice: ColorRect = $TopicChoice
@onready var topic_title: Label = $TopicTitle
@onready var click_sfx: AudioStreamPlayer = $Click
@onready var dialog_sfx: AudioStreamPlayer = $DialogSFX

var close_arrow: TextureRect = null
var _arrow_tween: Tween = null

var _current_patient: PatientData = null
var _buttons: Dictionary = {}  # Topic.Name -> Button


func _ready() -> void:
	_build_buttons()
	dialog_panel.gui_input.connect(_on_dialog_panel_input)
	dialog_sfx.stream = SfxUtil.first_available([
		"res://Assets/Audio/Voice/SFX jilly talk loop.mp3",
		"res://Assets/SFX/Click-1.mp3",
	])
	_setup_close_arrow()
	_start_close_arrow_animation()


func _setup_close_arrow() -> void:
	# Sembunyikan tombol close lama (kalau masih ada di scene/editor).
	for child in dialog_panel.get_children():
		if child is Button:
			child.visible = false
			child.disabled = true
	# Ambil panah kalau sudah ada di scene; kalau tidak, buat otomatis.
	var node := dialog_panel.get_node_or_null("CloseArrow")
	if node is TextureRect:
		close_arrow = node
	else:
		close_arrow = TextureRect.new()
		close_arrow.name = "CloseArrow"
		close_arrow.texture = load(DOWN_ARROW_TEXTURE) as Texture2D
		close_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		close_arrow.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		close_arrow.offset_left = -24.0
		close_arrow.offset_top = -48.0
		close_arrow.offset_right = 24.0
		close_arrow.offset_bottom = 0.0
		dialog_panel.add_child(close_arrow)


func _build_buttons() -> void:
	var nodes := [
		$TopicButton0, $TopicButton1, $TopicButton2,
		$TopicButton3, $TopicButton4, $TopicButton5,
	]
	for i in Topic.ALL_TOPICS.size():
		var topic: Topic.Name = Topic.ALL_TOPICS[i]
		var button: Button = nodes[i] as Button
		button.text = Topic.display_name(topic)
		button.pressed.connect(_on_topic_pressed.bind(topic))
		_buttons[topic] = button


func open_dialogue(patient: PatientData) -> void:
	_current_patient = patient
	_setup_choice_mode()
	visible = true


func _setup_choice_mode() -> void:
	dialog_label.text = OPEN_TEXT
	dialog_panel.offset_right = DIALOG_PANEL_DEFAULT
	topic_choice.visible = true
	topic_title.visible = true
	topic_choice.modulate.a = 1.0
	topic_title.modulate.a = 1.0
	for topic in _buttons:
		var button: Button = _buttons[topic]
		var used := _current_patient != null and _current_patient.topics_used.has(topic)
		button.visible = true
		button.modulate.a = 0.4 if used else 1.0
		button.disabled = used


func show_response(patient: PatientData, topic: Topic.Name) -> void:
	_current_patient = patient
	await _expand_dialog_panel()
	await get_tree().create_timer(TYPE_START_DELAY).timeout
	await _type_text(patient.get_dialog(topic))


func _expand_dialog_panel() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(dialog_panel, "offset_right", DIALOG_PANEL_EXPANDED, 0.3)
	tween.parallel().tween_property(topic_choice, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(topic_title, "modulate:a", 0.0, 0.2)
	for topic in _buttons:
		tween.parallel().tween_property(_buttons[topic], "modulate:a", 0.0, 0.2)
	await tween.finished
	topic_choice.visible = false
	topic_title.visible = false
	for topic in _buttons:
		_buttons[topic].visible = false


func _type_text(full_text: String) -> void:
	dialog_label.text = ""
	if dialog_sfx and dialog_sfx.stream:
		dialog_sfx.play()
	for i in full_text.length():
		dialog_label.text = full_text.substr(0, i + 1)
		await get_tree().create_timer(TYPE_INTERVAL).timeout
	if dialog_sfx and dialog_sfx.playing:
		dialog_sfx.stop()


func _on_topic_pressed(topic: Topic.Name) -> void:
	if click_sfx and click_sfx.stream:
		click_sfx.play()
	topic_selected.emit(topic)


func _on_dialog_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close()


func _close() -> void:
	if click_sfx and click_sfx.stream:
		click_sfx.play()
	dialogue_finished.emit()


func close_dialogue() -> void:
	visible = false


func _start_close_arrow_animation() -> void:
	if close_arrow == null:
		return
	_arrow_tween = create_tween().set_loops()
	_arrow_tween.tween_property(close_arrow, "offset_top", -52.0, 0.35)
	_arrow_tween.parallel().tween_property(close_arrow, "offset_bottom", -4.0, 0.35)
	_arrow_tween.tween_property(close_arrow, "offset_top", -48.0, 0.35)
	_arrow_tween.parallel().tween_property(close_arrow, "offset_bottom", 0.0, 0.35)
