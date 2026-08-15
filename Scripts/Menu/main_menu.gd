extends CanvasLayer

# Referensi ke node yang dibutuhkan
@onready var background = $Background
@onready var frontground = $Frontground 
@onready var button_container: Control = $Button

func _ready() -> void:
	visible = true
	AudioFade.fade_in($BGM, 2)
	get_tree().paused = false

func _on_start_pressed() -> void:
	$SFX_Click.play() 
	
	# 1. Sembunyikan elemen depan (Frontground) dan Tombol agar transisi bersih
	frontground.visible = false
	button_container.visible = false
	
	# 2. Atur pivot (titik tumpu) background ke tengah
	if "pivot_offset" in background and "size" in background:
		background.pivot_offset = background.size / 2.0
	
	# --- PERUBAHAN DI SINI ---
	# Ubah angka 3.0 di bawah ini untuk mengatur seberapa lambat transisinya
	# Semakin besar angkanya, semakin lambat zoom-nya.
	var zoom_duration: float = 3.0 
	
	# 3. Buat animasi Zoom In untuk Latar Belakang
	var tween := create_tween()
	tween.tween_property(background, "scale", Vector2(3.0, 3.0), zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# 4. Jalankan fade out audio dan ganti scene menggunakan durasi yang sama
	AudioFade.fade_out($BGM, zoom_duration)
	FadeToBlack.fade_to_scene("res://Scenes/main.tscn", zoom_duration)

func _on_exit_pressed() -> void:
	get_tree().quit()
