extends CanvasLayer

@onready var background = $Background
@onready var frontground = $Frontground
@onready var button_container: Control = $Button
@onready var title_container: Control = $Title
@onready var volume_container: Control = $Volume

# Catatan: Jika $Label throw error (null), sesuaikan path-nya ke $Volume/Label atau $Title/TitleLabel
@onready var label = $Volume/Label

func _ready() -> void:
	visible = true
	AudioFade.fade_in($BGM, 2)
	get_tree().paused = false

func _on_start_pressed() -> void:
	$SFX_Click.play() 
	
	frontground.visible = true
	button_container.visible = false
	title_container.visible = false
	volume_container.visible = false
	
	if "pivot_offset" in background and "size" in background:
		background.pivot_offset = background.size / 2.0
		
	if "pivot_offset" in label and "size" in label:
		label.pivot_offset = label.size / 2.0
	
	if "pivot_offset" in frontground and "size" in frontground:
		frontground.pivot_offset = frontground.size / 2.0
	
	var zoom_duration: float = 3.0 
	var zoom_factor: float = 3.0
	
	var bg_target_scale = background.scale * zoom_factor
	var fg_target_scale = frontground.scale * zoom_factor
	var lb_target_scale = label.scale * zoom_factor
	
	var tween := create_tween()
	
	tween.tween_property(background, "scale", bg_target_scale, zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(label, "scale", lb_target_scale, zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	tween.parallel().tween_property(frontground, "scale", fg_target_scale, zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	AudioFade.fade_out($BGM, zoom_duration)
	FadeToBlack.fade_to_scene("res://Scenes/main.tscn", zoom_duration)

func _on_exit_pressed() -> void:
	$SFX_Click.play() 
	get_tree().quit()
