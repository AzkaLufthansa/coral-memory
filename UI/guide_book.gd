extends Control

@onready var panel_container: Sprite2D = $PanelContainer
@onready var next_button: Button = $PanelContainer/ButtonOverlay/NextButton
@onready var close_button: Button = $PanelContainer/ButtonOverlay/CloseButton
@onready var paper_sound: AudioStreamPlayer = $Paper

var pages: Array[Node] = []
var current_page_index: int = 0

func _ready() -> void:
	# Hubungkan signal pressed ke fungsi
	#next_button.pressed.connect(_on_next_button_pressed)
	#close_button.pressed.connect(_on_close_button_pressed)
	
	# Mengumpulkan semua node halaman secara otomatis
	# Kita mengambil semua child dari PanelContainer kecuali ButtonOverlay
	for child in panel_container.get_children():
		if child.name != "ButtonOverlay":
			pages.append(child)
			
	# Tampilkan halaman pertama saat awal mula
	update_page_visibility()

func update_page_visibility() -> void:
	if pages.is_empty():
		return
		
	# Looping ke semua halaman yang terdaftar
	# Halaman akan terlihat (visible = true) hanya jika indeksnya sama dengan current_page_index
	for i in range(pages.size()):
		pages[i].visible = (i == current_page_index)

func _on_next_button_pressed() -> void:
	if pages.is_empty():
		return
		
	# Putar suara kertas
	if paper_sound and paper_sound.stream:
		paper_sound.play()
	
	# Lanjut ke halaman berikutnya (menggunakan modulo % agar kembali ke 0 jika sudah di akhir)
	current_page_index = (current_page_index + 1) % pages.size()
	
	# Perbarui tampilan
	update_page_visibility()

func _on_close_button_pressed() -> void:
	# Sembunyikan buku saat tombol close diklik
	visible = false
