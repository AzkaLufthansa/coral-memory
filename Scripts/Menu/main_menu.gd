extends CanvasLayer

func _ready() -> void:
	visible = true
	AudioFade.fade_in($BGM, 2)
	get_tree().paused = false
	$Settings/Sound/Value.text = str(int(UserSettings.master_volume * 10))
	$Settings/Music/Value.text = str(int(UserSettings.music_volume * 10))

func _on_start_pressed():
	$Start_SFX_Click.play()
	AudioFade.fade_out($BGM, 4)
	FadeToBlack.fade_to_scene("uid://bnbxspvlgp2tj", 4)

func _on_settings_pressed():
	$SFX_Click.play()
	$Settings.visible = true
	$Button.visible = false

func _on_exit_pressed():
	get_tree().quit()

func _on_confirm_pressed():
	$SFX_Click.play()
	$Settings.visible = false
	$Button.visible = true
	UserSettings.save_settings()


func _on_decrease_pressed():
	$SFX_Click.play()
	if UserSettings.master_volume > 0:
		UserSettings.master_volume -= 0.1
		$Settings/Sound/Value.text = str(int(UserSettings.master_volume * 10))
		UserSettings.apply_settings()

func _on_increase_pressed():
	$SFX_Click.play()
	if UserSettings.master_volume < 1.0:
		UserSettings.master_volume += 0.1
		$Settings/Sound/Value.text = str(int(UserSettings.master_volume * 10))
		UserSettings.apply_settings()

func _on_decrease2_pressed():
	$SFX_Click.play()
	if UserSettings.music_volume > 0:
		UserSettings.music_volume -= 0.1
		$Settings/Music/Value.text = str(int(UserSettings.music_volume * 10))
		UserSettings.apply_settings()

func _on_increase2_pressed():
	$SFX_Click.play()
	if UserSettings.music_volume < 1.0:
		UserSettings.music_volume += 0.1
		$Settings/Music/Value.text = str(int(UserSettings.music_volume * 10))
		UserSettings.apply_settings()
