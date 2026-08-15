extends CanvasLayer

func _ready() -> void:
	visible = true
	AudioFade.fade_in($BGM, 2)
	get_tree().paused = false


func _on_start_pressed() -> void:
	$SFX_Click.play()
	AudioFade.fade_out($BGM, 4)
	FadeToBlack.fade_to_scene("res://Scenes/main.tscn", 4)


func _on_exit_pressed() -> void:
	get_tree().quit()
