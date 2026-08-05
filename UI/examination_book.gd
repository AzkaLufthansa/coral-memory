extends Control

signal book_closed
signal report_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule, notes: String)

const PAGE_CATALOG := 0
const PAGE_DIAGNOSIS := 1

@onready var paper: TextureRect = %Paper
@onready var title_label: Label = %TitleLabel
@onready var content_label: Label = %ContentLabel
@onready var page_label: Label = %PageLabel
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton
@onready var close_button: Button = %CloseButton
@onready var diagnosis_button: Button = %DiagnosisButton

@onready var catalog_panel: Control = %CatalogPanel
@onready var diagnosis_panel: Control = %DiagnosisPanel
@onready var emotion_label: Label = %EmotionLabel
@onready var schedule_label: Label = %ScheduleLabel
@onready var submit_button: Button = %SubmitButton
@onready var notes_input: TextEdit = %NotesInput

var _catalog: Array = []
var _catalog_index := 0
var _page := PAGE_CATALOG
var _emotion_buttons: Dictionary = {}
var _schedule_buttons: Dictionary = {}
var _selected_emotion: Emotion.Type = -1
var _selected_schedule: GameConfig.Schedule = -1


func _ready() -> void:
	_catalog = EchoCatalog.all()
	_build_emotion_buttons()
	_build_schedule_buttons()
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	close_button.pressed.connect(func() -> void: book_closed.emit())
	diagnosis_button.pressed.connect(_on_diagnosis_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	submit_button.disabled = true
	notes_input.text_changed.connect(func(_t): pass)


func show_book() -> void:
	_catalog_index = 0
	_goto_catalog()
	visible = true


func hide_book() -> void:
	visible = false


func _goto_catalog() -> void:
	_page = PAGE_CATALOG
	catalog_panel.visible = true
	diagnosis_panel.visible = false
	_show_catalog_entry()


func _show_catalog_entry() -> void:
	var entry: Dictionary = _catalog[_catalog_index]
	title_label.text = "%s — %s" % [entry["name"], entry["emotion"]]
	content_label.text = "Wujud:\n%s\n\nBahasa tubuh:\n%s\n\nPola bicara:\n%s\n\nPetunjuk kunci:\n%s" % [
		entry["visual"], entry["body"], entry["dialog"], entry["clue"]
	]
	page_label.text = "%d / %d" % [_catalog_index + 1, _catalog.size()]
	prev_button.disabled = _catalog_index == 0
	next_button.disabled = _catalog_index >= _catalog.size() - 1


func _on_prev_pressed() -> void:
	if _page == PAGE_CATALOG and _catalog_index > 0:
		_catalog_index -= 1
		_show_catalog_entry()


func _on_next_pressed() -> void:
	if _page == PAGE_CATALOG and _catalog_index < _catalog.size() - 1:
		_catalog_index += 1
		_show_catalog_entry()


func _on_diagnosis_pressed() -> void:
	_page = PAGE_DIAGNOSIS
	catalog_panel.visible = false
	diagnosis_panel.visible = true
	_selected_emotion = -1
	_selected_schedule = -1
	for button in _emotion_buttons.values():
		button.button_pressed = false
	for button in _schedule_buttons.values():
		button.button_pressed = false
	emotion_label.text = "Core Echo: -"
	schedule_label.text = "Jadwal Kontrol: -"
	submit_button.disabled = true


func _build_emotion_buttons() -> void:
	var grid := %EmotionGrid as GridContainer
	for emotion in Emotion.Type.values():
		var button := Button.new()
		button.text = Emotion.display_name(emotion)
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(140, 40)
		button.toggled.connect(_on_emotion_toggled.bind(emotion))
		grid.add_child(button)
		_emotion_buttons[emotion] = button


func _build_schedule_buttons() -> void:
	var box := %ScheduleBox as HBoxContainer
	for schedule in GameConfig.Schedule.values():
		var button := Button.new()
		button.text = GameConfig.schedule_label(schedule)
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(140, 40)
		button.toggled.connect(_on_schedule_toggled.bind(schedule))
		box.add_child(button)
		_schedule_buttons[schedule] = button


func _on_emotion_toggled(pressed: bool, emotion: Emotion.Type) -> void:
	if pressed:
		_selected_emotion = emotion
		emotion_label.text = "Core Echo: %s" % Emotion.display_name(emotion)
		for other in _emotion_buttons:
			if other != emotion:
				_emotion_buttons[other].button_pressed = false
	else:
		if _selected_emotion == emotion:
			_selected_emotion = -1
			emotion_label.text = "Core Echo: -"
	_update_submit()


func _on_schedule_toggled(pressed: bool, schedule: GameConfig.Schedule) -> void:
	if pressed:
		_selected_schedule = schedule
		schedule_label.text = "Jadwal Kontrol: %s" % GameConfig.schedule_label(schedule)
		for other in _schedule_buttons:
			if other != schedule:
				_schedule_buttons[other].button_pressed = false
	else:
		if _selected_schedule == schedule:
			_selected_schedule = -1
			schedule_label.text = "Jadwal Kontrol: -"
	_update_submit()


func _update_submit() -> void:
	submit_button.disabled = _selected_emotion == -1 or _selected_schedule == -1


func _on_submit_pressed() -> void:
	if _selected_emotion == -1 or _selected_schedule == -1:
		return
	hide_book()
	report_submitted.emit(_selected_emotion, _selected_schedule, notes_input.text)
