class_name EchoElement
extends Node2D

@export var emotion: Emotion.Type = Emotion.Type.FEAR

var reveal_level: float = 0.0  # 0 = tersembunyi, 0.5 = secondary, 1.0 = primary
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func set_reveal(level: float) -> void:
	reveal_level = maxf(reveal_level, level)
	visible = reveal_level > 0.01
	queue_redraw()


func reset_reveal() -> void:
	reveal_level = 0.0
	visible = false


func _draw() -> void:
	if reveal_level <= 0.01:
		return
	var alpha := clampf(reveal_level, 0.0, 1.0)
	var pulse := 1.0 + sin(_time * 2.0) * 0.05
	match emotion:
		Emotion.Type.FEAR:
			_draw_fear(alpha, pulse)
		Emotion.Type.ANGER:
			_draw_anger(alpha, pulse)
		Emotion.Type.SADNESS:
			_draw_sadness(alpha, pulse)
		Emotion.Type.GUILT:
			_draw_guilt(alpha, pulse)
		Emotion.Type.SHAME:
			_draw_shame(alpha, pulse)
		Emotion.Type.ENVY:
			_draw_envy(alpha, pulse)


func _line(points: PackedVector2Array, color: Color, width: float) -> void:
	if points.size() >= 2:
		draw_polyline(points, color, width, true)


func _draw_fear(alpha: float, pulse: float) -> void:
	var color := Color(0.85, 0.88, 0.95, alpha)
	_line(PackedVector2Array([Vector2(-24, -10), Vector2(-12, -2), Vector2(-20, 8), Vector2(-6, 14)]), color, 1.6 * pulse)
	_line(PackedVector2Array([Vector2(6, -20), Vector2(14, -6), Vector2(4, 2)]), color, 1.4 * pulse)
	_line(PackedVector2Array([Vector2(20, -4), Vector2(10, 4), Vector2(22, 12)]), color, 1.3 * pulse)


func _draw_anger(alpha: float, pulse: float) -> void:
	var color := Color(0.95, 0.45, 0.2, alpha)
	var flame := PackedVector2Array([
		Vector2(0, 14), Vector2(-8, -2), Vector2(-3, 2), Vector2(0, -10), Vector2(3, 2), Vector2(8, -2)
	])
	draw_colored_polygon(flame, color)
	draw_circle(Vector2(-14, -6), 2.5 * pulse, color)
	draw_circle(Vector2(12, 2), 2.0 * pulse, color)


func _draw_sadness(alpha: float, pulse: float) -> void:
	var color := Color(0.45, 0.3, 0.25, alpha)
	for i in 4:
		var x := -18.0 + i * 12.0
		var len := 16.0 + i * 4.0
		_line(PackedVector2Array([Vector2(x, 6), Vector2(x + 3, 6 + len * 0.5), Vector2(x, 6 + len)]), color, 2.0 * pulse)


func _draw_guilt(alpha: float, pulse: float) -> void:
	var white := Color(0.95, 0.95, 0.95, alpha)
	var dark := Color(0.15, 0.12, 0.12, alpha)
	for i in 3:
		var x := -14.0 + i * 14.0
		var y := -6.0 + (i % 2) * 4.0
		draw_circle(Vector2(x, y), 4.0 * pulse, white)
		draw_circle(Vector2(x + 1, y), 1.8 * pulse, dark)


func _draw_shame(alpha: float, pulse: float) -> void:
	var color := Color(0.7, 0.6, 0.75, alpha)
	for i in 3:
		var inset := 6.0 + i * 6.0
		_line(PackedVector2Array([
			Vector2(-24 + inset, 10), Vector2(24 - inset, 10),
			Vector2(24 - inset, -10), Vector2(-24 + inset, -10)
		]), color, 1.5 * pulse)


func _draw_envy(alpha: float, pulse: float) -> void:
	var color := Color(0.5, 0.7, 0.5, alpha * 0.9)
	var twin := PackedVector2Array([
		Vector2(26, 12), Vector2(20, -6), Vector2(26, -12), Vector2(34, -6), Vector2(32, 12)
	])
	draw_colored_polygon(twin, color)
	draw_circle(Vector2(-22, 0), 8.0 * pulse, Color(0.4, 0.55, 0.4, alpha * 0.7))
