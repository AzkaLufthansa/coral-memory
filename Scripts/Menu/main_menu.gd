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
	
	# 1. Pastikan Frontground terlihat dan sembunyikan Tombol
	frontground.visible = true
	button_container.visible = false
	
	# 2. Atur pivot (titik tumpu) background DAN frontground ke tengah
	if "pivot_offset" in background and "size" in background:
		background.pivot_offset = background.size / 2.0
		
	if "pivot_offset" in frontground and "size" in frontground:
		frontground.pivot_offset = frontground.size / 2.0
	
	# Ubah angka 3.0 di bawah ini untuk mengatur seberapa lambat transisinya
	var zoom_duration: float = 3.0 
	
	# --- PERBAIKAN DI SINI (SOLUSI SKALA RELATIF) ---
	# Kita tentukan berapa kali lipat mereka membesar (misal: 3x lipat)
	var zoom_factor: float = 3.0
	
	# Hitung target skala akhir berdasarkan skala mereka saat ini
	var bg_target_scale = background.scale * zoom_factor
	var fg_target_scale = frontground.scale * zoom_factor
	
	# 3. Buat animasi Zoom In untuk Latar Belakang dan Depan
	var tween := create_tween()
	
	# Gunakan target yang sudah dihitung agar pertumbuhannya proporsional (kecepatan sama)
	# Zoom untuk background
	tween.tween_property(background, "scale", bg_target_scale, zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	# Menggunakan parallel() agar zoom frontground berjalan bersamaan dengan background
	tween.parallel().tween_property(frontground, "scale", fg_target_scale, zoom_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# 4. Jalankan fade out audio dan ganti scene menggunakan durasi yang sama
	AudioFade.fade_out($BGM, zoom_duration)
	FadeToBlack.fade_to_scene("res://Scenes/main.tscn", zoom_duration)

func _on_exit_pressed() -> void:
	get_tree().quit()
