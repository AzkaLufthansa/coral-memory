extends Control

signal flash_finished

const FLASH_COUNT := 3
const FLASH_UP := 0.15
const FLASH_DOWN := 0.15

@onready var rect: ColorRect = $FlashRect


func _ready() -> void:
	rect.modulate.a = 0.0
	visible = false


func play() -> void:
	if visible:
		return
	visible = true
	var tween := create_tween()
	for i in FLASH_COUNT:
		tween.tween_property(rect, "modulate:a", 1.0, FLASH_UP)
		tween.tween_property(rect, "modulate:a", 0.0, FLASH_DOWN)
	await tween.finished
	visible = false
	flash_finished.emit()
