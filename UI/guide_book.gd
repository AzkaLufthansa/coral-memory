extends Control

signal closed

@onready var panel_container: Sprite2D = $PanelContainer
@onready var next_button: Button = $PanelContainer/ButtonOverlay/NextButton
@onready var close_button: Button = $PanelContainer/ButtonOverlay/CloseButton
@onready var paper_sound: AudioStreamPlayer = $Paper

var pages: Array[Node] = []
var current_page_index: int = 0

func _ready() -> void:

	for child in panel_container.get_children():
		if child.name != "ButtonOverlay":
			pages.append(child)
			
	
	update_page_visibility()

func update_page_visibility() -> void:
	if pages.is_empty():
		return
		
	
	for i in range(pages.size()):
		pages[i].visible = (i == current_page_index)

func _on_next_button_pressed() -> void:
	if pages.is_empty():
		return
		
	
	if paper_sound and paper_sound.stream:
		paper_sound.play()
	
	current_page_index = (current_page_index + 1) % pages.size()
	
	update_page_visibility()

func _on_close_button_pressed() -> void:
	visible = false
	closed.emit()
