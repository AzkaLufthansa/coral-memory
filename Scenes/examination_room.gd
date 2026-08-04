extends Node2D

# Ruang Pemeriksaan 2D — placeholder seluruhnya dari primitif Godot.
# Satu scene mandiri agar mudah diganti dengan art final tanpa mengubah logika game.
#
# Layar desain: 1152x648 (sesuai project window default + stretch canvas_items).

const DESIGN := Vector2(1152, 648)

# Palet (Section VISUAL STYLE)
const WALL := Color(0.62, 0.64, 0.68)
const WALL_PANEL := Color(0.7, 0.72, 0.76)
const FLOOR := Color(0.34, 0.36, 0.4)
const DARK_GLASS := Color(0.09, 0.12, 0.16)
const METAL := Color(0.29, 0.3, 0.34)
const DESK := Color(0.2, 0.22, 0.26)
const ACCENT := Color(0.35, 0.83, 0.88)
const CABINET := Color(0.35, 0.37, 0.42)
const LIGHT_TEXT := Color(0.85, 0.87, 0.9)


func _draw() -> void:
	var size := get_viewport_rect().size
	var s := size / DESIGN

	# --- Dinding belakang ---
	draw_rect(Rect2(0, 0, size.x, 400 * s.y), WALL)
	_draw_panels(s)

	# --- Lampu langit-langit ---
	_draw_ceiling_lights(s)

	# --- Jendela observasi (tengah belakang) ---
	_draw_window(s)

	# --- Pintu geser otomatis (kiri) ---
	_draw_sliding_door(s)

	# --- Logo pemerintah (kanan jendela) ---
	_draw_gov_logo(s)

	# --- Jam dinding (kiri atas) ---
	_draw_wall_clock(s)

	# --- Display digital info pasien (kiri) ---
	_draw_patient_display(s)

	# --- Kabinet penyimpanan (kanan) ---
	_draw_cabinet(s)

	# --- Lantai ---
	draw_rect(Rect2(0, 400 * s.y, size.x, (648 - 400) * s.y), FLOOR)
	draw_line(Vector2(0, 400 * s.y), Vector2(size.x, 400 * s.y), Color(0.5, 0.52, 0.56), 2.0)

	# --- Kursi pasien (tengah, di belakang pasien) ---
	_draw_patient_chair(s)

	# --- Meja pemeriksaan (foreground bawah) ---
	_draw_desk(s)


func _draw_panels(s: Vector2) -> void:
	# Panel dinding minimalis
	for i in 6:
		var x := 60.0 + i * 180.0
		draw_rect(Rect2(x * s.x, 50 * s.y, 150 * s.x, 300 * s.y), WALL_PANEL)


func _draw_ceiling_lights(s: Vector2) -> void:
	for i in 3:
		var cx := 260.0 + i * 340.0
		draw_rect(Rect2((cx - 70) * s.x, 18 * s.y, 140 * s.x, 10 * s.y), Color(0.55, 0.9, 0.95, 0.9))
		draw_rect(Rect2((cx - 72) * s.x, 16 * s.y, 144 * s.x, 4 * s.y), ACCENT)


func _draw_window(s: Vector2) -> void:
	var rect := Rect2(420 * s.x, 60 * s.y, 330 * s.x, 250 * s.y)
	draw_rect(rect, DARK_GLASS)
	# bingkai
	draw_rect(Rect2(rect.position.x - 8 * s.x, rect.position.y - 8 * s.y, rect.size.x + 16 * s.x, rect.size.y + 16 * s.y), METAL, false, 6.0)
	# pantulan cyan redup
	draw_rect(Rect2((420 + 20) * s.x, (60 + 20) * s.y, 60 * s.x, 6 * s.y), Color(0.35, 0.83, 0.88, 0.25))
	# garis vertikal bingkai
	draw_line(Vector2(rect.position.x + rect.size.x / 2, rect.position.y), Vector2(rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y), METAL, 4.0)


func _draw_sliding_door(s: Vector2) -> void:
	# Pintu geser dua panel di dinding kiri
	var door_x := 40.0
	var door_w := 150.0
	for i in 2:
		var x := (door_x + i * 74.0) * s.x
		draw_rect(Rect2(x, 150 * s.y, 72 * s.x, 250 * s.y), METAL)
		# relung garis tengah pintu
		draw_line(Vector2(x + 36 * s.x, 160 * s.y), Vector2(x + 36 * s.x, 390 * s.y), Color(0.2, 0.21, 0.24), 2.0)
	# garis rel atas & bawah
	draw_line(Vector2(door_x * s.x, 145 * s.y), Vector2((door_x + door_w) * s.x, 145 * s.y), Color(0.45, 0.47, 0.52), 3.0)
	draw_line(Vector2(door_x * s.x, 405 * s.y), Vector2((door_x + door_w) * s.x, 405 * s.y), Color(0.45, 0.47, 0.52), 3.0)
	# label pintu
	_draw_text("MASUK / KELUAR", Vector2((door_x + door_w / 2) * s.x, 430 * s.y), 12, Color(0.6, 0.62, 0.66), s)


func _draw_gov_logo(s: Vector2) -> void:
	var center := Vector2(880, 130) * s
	draw_circle(center, 42 * s.x, Color(0.9, 0.92, 0.95))
	draw_arc(center, 42 * s.x, 0, TAU, 48, METAL, 3.0)
	draw_circle(center, 26 * s.x, ACCENT)
	draw_circle(center, 12 * s.x, Color(0.9, 0.92, 0.95))
	_draw_text("FASILITAS OBSERVASI ECHO", Vector2(center.x, (130 + 60) * s.y), 13, Color(0.75, 0.78, 0.82), s)


func _draw_wall_clock(s: Vector2) -> void:
	var center := Vector2(1050, 110) * s
	draw_circle(center, 30 * s.x, Color(0.93, 0.94, 0.96))
	draw_arc(center, 30 * s.x, 0, TAU, 48, METAL, 2.5)
	# jarum
	draw_line(center, center + Vector2(0, -18) * s.x, Color(0.25, 0.26, 0.3), 2.5)
	draw_line(center, center + Vector2(12, 8) * s.x, Color(0.25, 0.26, 0.3), 2.0)
	draw_circle(center, 3 * s.x, Color(0.25, 0.26, 0.3))


func _draw_patient_display(s: Vector2) -> void:
	var rect := Rect2(70 * s.x, 70 * s.y, 190 * s.x, 120 * s.y)
	draw_rect(rect, Color(0.06, 0.08, 0.1))
	draw_rect(rect, METAL, false, 3.0)
	# teks "simulasi" info pasien
	_draw_text("PASIEN 003", Vector2(rect.position.x + rect.size.x / 2, rect.position.y + 30 * s.y), 14, ACCENT, s)
	_draw_text("STATUS: DALAM PERIKSA", Vector2(rect.position.x + rect.size.x / 2, rect.position.y + 56 * s.y), 10, Color(0.55, 0.85, 0.6), s)


func _draw_cabinet(s: Vector2) -> void:
	var rect := Rect2(980 * s.x, 210 * s.y, 120 * s.x, 190 * s.y)
	draw_rect(rect, CABINET)
	draw_rect(Rect2(rect.position.x + 8 * s.x, rect.position.y + 8 * s.y, rect.size.x - 16 * s.x, rect.size.y - 16 * s.y), Color(0.3, 0.32, 0.37))
	# gagang
	for i in 3:
		var y := rect.position.y + 30 * s.y + i * 60 * s.y
		draw_line(Vector2(rect.position.x + 14 * s.x, y), Vector2(rect.position.x + 14 * s.x, y + 16 * s.y), Color(0.7, 0.72, 0.76), 3.0)
	_draw_text("ARSIP", Vector2(rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y + 18 * s.y), 12, Color(0.6, 0.62, 0.66), s)


func _draw_patient_chair(s: Vector2) -> void:
	# Kursi pasien menghadap meja/player (tengah)
	var cx := 640.0
	var base_y := 400.0
	var seat := Rect2((cx - 45) * s.x, (base_y - 55) * s.y, 90 * s.x, 12 * s.y)
	draw_rect(seat, METAL)
	# sandaran
	draw_rect(Rect2((cx - 45) * s.x, (base_y - 100) * s.y, 12 * s.x, 48 * s.y), METAL)
	# kaki
	for dx in [-35.0, 35.0]:
		draw_line(Vector2((cx + dx) * s.x, (base_y - 43) * s.y), Vector2((cx + dx) * s.x, base_y * s.y), Color(0.2, 0.21, 0.24), 5.0)


func _draw_desk(s: Vector2) -> void:
	# Meja pemeriksaan di foreground bawah
	var top_y := 470.0
	var desk_rect := Rect2(200 * s.x, top_y * s.y, 752 * s.x, 14 * s.y)
	draw_rect(desk_rect, DESK)
	draw_rect(Rect2(200 * s.x, (top_y + 14) * s.y, 752 * s.x, 164 * s.y), Color(0.14, 0.15, 0.18))
	# aksen cyan di tepi meja
	draw_rect(Rect2(200 * s.x, (top_y - 3) * s.y, 752 * s.x, 3 * s.y), ACCENT)
	# kaki meja
	for dx in [240.0, 912.0]:
		draw_rect(Rect2((dx - 8) * s.x, (top_y + 18) * s.y, 16 * s.x, 160 * s.y), DESK)


func _draw_text(text: String, pos: Vector2, font_size: float, color: Color, s: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var fsize := int(font_size * minf(s.x, s.y))
	draw_string(font, pos - Vector2(0, font_size), text, HORIZONTAL_ALIGNMENT_CENTER, 300 * s.x, fsize, color)
