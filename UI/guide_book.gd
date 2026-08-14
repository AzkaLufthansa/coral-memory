extends PanelContainer

# Referensi ke Elemen Halaman Kiri (Hal1)
@onready var hal1_label: Label = $PanelContainer/MarginContainer/Lembar1/Hal1/Label
@onready var hal1_texture: TextureRect = $PanelContainer/MarginContainer/Lembar1/Hal1/TextureRect
@onready var hal1_desc: Label = $PanelContainer/MarginContainer/Lembar1/Hal1/DescriptionLabel

# Referensi ke Elemen Halaman Kanan (Hal2)
@onready var hal2_label: Label = $PanelContainer/MarginContainer/Lembar1/Hal2/Label
@onready var hal2_texture: TextureRect = $PanelContainer/MarginContainer/Lembar1/Hal2/TextureRect
@onready var hal2_desc: Label = $PanelContainer/MarginContainer/Lembar1/Hal2/DescriptionLabel

# Referensi ke Tombol Navigasi
@onready var next_button: Button = $PanelContainer/ButtonOverlay/Button

# Indeks halaman saat ini (dimulai dari 0)
var current_page_index: int = 0

# Data Konten Buku
# Anda bisa menambah/mengubah isi daftar ini sesuai kebutuhan game Anda
var pages_data: Array[Dictionary] = [
	{
		"title": "Panduan 1",
		"texture": preload("res://icon.svg"), # Ganti dengan path sprite/gambar Anda
		"desc": "Deskripsi panduan untuk halaman pertama."
	},
	{
		"title": "Panduan 2",
		"texture": preload("res://icon.svg"), # Ganti dengan path sprite/gambar Anda
		"desc": "Deskripsi panduan untuk halaman kedua."
	},
	{
		"title": "Panduan 3",
		"texture": preload("res://icon.svg"),
		"desc": "Deskripsi panduan untuk halaman ketiga."
	},
	{
		"title": "Panduan 4",
		"texture": preload("res://icon.svg"),
		"desc": "Deskripsi panduan untuk halaman keempat."
	}
]


func _ready() -> void:
	# Hubungkan sinyal klik tombol panah
	next_button.pressed.connect(_on_next_button_pressed)
	
	# Muat tampilan awal buku
	update_book_pages()


# Otomatis reset ke halaman 0 setiap kali buku ini ditampilkan (visible = true)
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		current_page_index = 0
		update_book_pages()


func _on_next_button_pressed() -> void:
	# Karena 1 tampilan buku memuat 2 halaman (Hal1 & Hal2), kita melompat 2 angka
	if current_page_index + 2 < pages_data.size():
		current_page_index += 2
		update_book_pages()
	else:
		# Jika tombol diklik di halaman paling akhir, buku akan tertutup
		hide()


func update_book_pages() -> void:
	# --- UPDATE HALAMAN KIRI (Hal1) ---
	if current_page_index < pages_data.size():
		var data_kiri = pages_data[current_page_index]
		hal1_label.text = data_kiri["title"]
		hal1_desc.text = data_kiri["desc"]
		if data_kiri["texture"]:
			hal1_texture.texture = data_kiri["texture"]
		$PanelContainer/MarginContainer/Lembar1/Hal1.visible = true
	else:
		$PanelContainer/MarginContainer/Lembar1/Hal1.visible = false

	# --- UPDATE HALAMAN KANAN (Hal2) ---
	if current_page_index + 1 < pages_data.size():
		var data_kanan = pages_data[current_page_index + 1]
		hal2_label.text = data_kanan["title"]
		hal2_desc.text = data_kanan["desc"]
		if data_kanan["texture"]:
			hal2_texture.texture = data_kanan["texture"]
		$PanelContainer/MarginContainer/Lembar1/Hal2.visible = true
	else:
		$PanelContainer/MarginContainer/Lembar1/Hal2.visible = false


# Opsional: Tutup buku jika pemain menekan tombol ESC di keyboard
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide()
