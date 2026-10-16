extends Node2D

var is_able_to_proceed = [false, false]

func _ready() -> void:
	AudioFade.fade_in($BGM, 3.0, -3.0)

func _on_button_pressed() -> void:
	$Label/ColorRect/Button1.disabled = true
	$Reveal.play(8.4)
	var blur_overlay = $Label/ColorRect
	var tween = create_tween()
	if blur_overlay.modulate.a > 0:
		# Fade out the blur
		tween.tween_property(blur_overlay, "modulate:a", 0.0, 0.3)
	await tween.finished
	is_able_to_proceed[0] = true
	check_for_proceed()

func _on_button_2_pressed() -> void:
	$ColorRect2/Button1.disabled = true
	$Reveal.play(8.4)
	var blur_overlay = $ColorRect2
	var tween = create_tween()
	if blur_overlay.modulate.a > 0:
		# Fade out the blur
		tween.tween_property(blur_overlay, "modulate:a", 0.0, 0.3)
	await tween.finished
	is_able_to_proceed[1] = true
	check_for_proceed()

func check_for_proceed() -> void:
	if is_able_to_proceed[0] and is_able_to_proceed[1]:
		$Title2.text = "Tekan Ini Untuk Lanjut"

#func _on_button_3_pressed() -> void:
	#$ColorRect3/Button3.disabled = true
	#var blur_overlay = $ColorRect3
	#var tween = create_tween()
	#if blur_overlay.modulate.a > 0:
		## Fade out the blur
		#tween.tween_property(blur_overlay, "modulate:a", 0.0, 0.3)
#
#func _on_button_4_pressed() -> void:
	#$ColorRect4/Button4.disabled = true
	#var blur_overlay = $ColorRect4
	#var tween = create_tween()
	#if blur_overlay.modulate.a > 0:
		## Fade out the blur
		#tween.tween_property(blur_overlay, "modulate:a", 0.0, 0.3)
#
#func _on_button_5_pressed() -> void:
	#$ColorRect5/Button5.disabled = true
	#var blur_overlay = $ColorRect5
	#var tween = create_tween()
	#if blur_overlay.modulate.a > 0:
		## Fade out the blur
		#tween.tween_property(blur_overlay, "modulate:a", 0.0, 0.3)
#
#func _on_button_6_pressed() -> void:
	#$ColorRect6/Button6.disabled = true
	#var blur_overlay = $ColorRect6
	#var tween = create_tween()
	#if blur_overlay.modulate.a > 0:
		## Fade out the blur
		#tween.tween_property(blur_overlay, "modulate:a", 0.0, 0.3)


func _on_done_button_pressed() -> void:
	AudioFade.fade_out($BGM, 3.0)
	$Langkah.play()
	$Langkah/Timer.start()
	FadeToBlack.fade_to_scene("res://Scenes/main.tscn", 5)
	Cursor.reset_cursor()
	$Area2D.input_pickable = false

func _on_timer_timeout() -> void:
	$Langkah.stop()
	$PintuBuka.play()

func _on_pintu_buka_finished() -> void:
	$PintuBuka.stop()
	$PintuTutup.play()

func _on_pintu_tutup_finished() -> void:
	$PintuTutup.stop()
