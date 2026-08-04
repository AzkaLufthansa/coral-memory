extends PanelContainer

signal topic_selected(topic: Topic.Name)

var _buttons: Dictionary = {}  # Topic.Name -> Button


func _ready() -> void:
	_build_buttons()


func _build_buttons() -> void:
	var grid := $Margin/VBox/Grid as GridContainer
	for topic in Topic.ALL_TOPICS:
		var button := Button.new()
		button.text = Topic.display_name(topic)
		button.custom_minimum_size = Vector2(140, 40)
		button.pressed.connect(_on_topic_pressed.bind(topic))
		grid.add_child(button)
		_buttons[topic] = button


func show_topics() -> void:
	for button in _buttons.values():
		button.disabled = false
		button.modulate = Color.WHITE
	visible = true


func disable_topic(topic: Topic.Name) -> void:
	var button: Button = _buttons.get(topic)
	if button:
		button.disabled = true
		button.modulate = Color(1, 1, 1, 0.4)


func hide_panel() -> void:
	visible = false


func _on_topic_pressed(topic: Topic.Name) -> void:
	disable_topic(topic)
	topic_selected.emit(topic)
