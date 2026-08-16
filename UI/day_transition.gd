extends Control

signal transition_finished

@onready var day_label: Label = %DayLabel
@onready var overlay: ColorRect = $Overlay


func _ready() -> void:
	overlay.color.a = 0.0
	visible = false


func show_day(day: int) -> void:
	visible = true
	day_label.text = "DAY %d" % day
	day_label.modulate.a = 0.0
	overlay.color.a = 1.0
	_tween()


func _tween() -> void:
	var tween := create_tween()
	# Fade in teks
	tween.tween_property(day_label, "modulate:a", 1.0, 0.8)
	tween.tween_interval(2.5)
	# Fade out semuanya
	tween.tween_property(day_label, "modulate:a", 0.0, 0.8)
	tween.tween_property(overlay, "color:a", 0.0, 0.8)
	tween.tween_callback(_finish)


func _finish() -> void:
	visible = false
	transition_finished.emit()
