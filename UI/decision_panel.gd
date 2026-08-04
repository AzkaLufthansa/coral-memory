extends PanelContainer

signal decision_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule)

@onready var emotion_label: Label = %EmotionLabel
@onready var schedule_label: Label = %ScheduleLabel
@onready var submit_button: Button = %SubmitButton

var _emotion_buttons: Dictionary = {}  # Emotion.Type -> Button
var _schedule_buttons: Dictionary = {}  # GameConfig.Schedule -> Button
var _selected_emotion: Emotion.Type = -1
var _selected_schedule: GameConfig.Schedule = -1


func _ready() -> void:
	_build_emotion_buttons()
	_build_schedule_buttons()
	submit_button.pressed.connect(_on_submit_pressed)
	submit_button.disabled = true


func _build_emotion_buttons() -> void:
	var grid := $Margin/VBox/EmotionGrid as GridContainer
	for emotion in Emotion.Type.values():
		var button := Button.new()
		button.text = Emotion.display_name(emotion)
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(150, 40)
		button.toggled.connect(_on_emotion_toggled.bind(emotion))
		grid.add_child(button)
		_emotion_buttons[emotion] = button


func _build_schedule_buttons() -> void:
	var box := $Margin/VBox/ScheduleBox as HBoxContainer
	for schedule in GameConfig.Schedule.values():
		var button := Button.new()
		button.text = GameConfig.schedule_label(schedule)
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(150, 40)
		button.toggled.connect(_on_schedule_toggled.bind(schedule))
		box.add_child(button)
		_schedule_buttons[schedule] = button


func show_panel() -> void:
	_selected_emotion = -1
	_selected_schedule = -1
	for button in _emotion_buttons.values():
		button.button_pressed = false
	for button in _schedule_buttons.values():
		button.button_pressed = false
	emotion_label.text = "Emosi Dominan: -"
	schedule_label.text = "Jadwal Kontrol: -"
	submit_button.disabled = true
	visible = true


func hide_panel() -> void:
	visible = false


func _on_emotion_toggled(pressed: bool, emotion: Emotion.Type) -> void:
	if pressed:
		_selected_emotion = emotion
		emotion_label.text = "Emosi Dominan: %s" % Emotion.display_name(emotion)
		for other in _emotion_buttons:
			if other != emotion:
				_emotion_buttons[other].button_pressed = false
	else:
		if _selected_emotion == emotion:
			_selected_emotion = -1
			emotion_label.text = "Emosi Dominan: -"
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
	hide_panel()
	decision_submitted.emit(_selected_emotion, _selected_schedule)
