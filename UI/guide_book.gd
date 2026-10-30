extends Control

signal closed

const FRAME_SIZE := 128
const FONT_PATH := "res://Assets/Fonts/Fusion Pixel 10px Monospaced/fusion-pixel-10px-monospaced-ja.otf"
const ENTRIES := [
	{"title": "Echo Dasar", "desc": "Belum menunjukkan emosi apa pun. Semakin banyak sisi pasien yang tersentuh, semakin jelas wujud aslinya berubah.", "sheet": "res://Assets/Echo/Initial.png"},
	{"title": "Echo Retak", "desc": "Retakan menjalar dan Echo menjauh setiap kali sisi yang ditakuti disinggung. Semakin jauh ia mundur, semakin dekat itu dengan yang ia hindari.", "sheet": "res://Assets/Echo/Fear.png"},
	{"title": "Echo Api", "desc": "Percikan api membara di tepi kabut; Echo membesar dan mendekat setiap kali amarah tersinggung.", "sheet": "res://Assets/Echo/Angry/Angry-Sheet.png"},
	{"title": "Echo Akar", "desc": "Akar menjuntai dari bawah kabut; Echo memberat dan turun, seolah ditarik masa lalu yang belum selesai.", "sheet": "res://Assets/Echo/Sad/Sad-Sheet.png"},
	{"title": "Echo Mata", "desc": "Mata-mata kecil muncul di permukaan kabut dan menatap pasien sendiri. Penyesalan yang tak henti mengawasi.", "sheet": "res://Assets/Echo/Guilt/Guilt-Sheet.png"},
	{"title": "Echo Lipat", "desc": "Echo melipat dan mengecil, bersembunyi di balik tubuh pasien; rasa malu yang tertuju pada diri sendiri.", "sheet": "res://Assets/Echo/Shame/Shame-Sheet.png"},
	{"title": "Echo Bayangan Kembar", "desc": "Echo membelah menjadi dua siluet; satu tetap di tempat, satu meniru sosok yang sedang dibicarakan.", "sheet": "res://Assets/Echo/Envy/Envy-Sheet.png"},
]

@onready var panel_container: Sprite2D = $PanelContainer
@onready var next_button: Button = $PanelContainer/ButtonOverlay/NextButton
@onready var close_button: Button = $PanelContainer/ButtonOverlay/CloseButton
@onready var paper_sound: AudioStreamPlayer = $Paper

var pages: Array[Node] = []
var current_page_index := 0
var _font: Font = null


func _ready() -> void:
	if ResourceLoader.exists(FONT_PATH):
		_font = load(FONT_PATH) as Font
	_build_pages()
	next_button.visible = pages.size() > 1
	next_button.anchor_right = 0.0
	next_button.anchor_bottom = 0.0
	next_button.offset_right = next_button.offset_left + 44.0
	next_button.offset_bottom = next_button.offset_top + 26.0
	update_page_visibility()


func _build_pages() -> void:
	var overlay := panel_container.get_node_or_null("ButtonOverlay")
	for child in panel_container.get_children():
		if child != overlay:
			child.visible = false
			child.queue_free()

	pages.clear()
	var page_count := int(ceil(ENTRIES.size() / 2.0))
	for i in range(page_count):
		var page := _make_page(i)
		panel_container.add_child(page)
		if overlay:
			panel_container.move_child(overlay, panel_container.get_child_count() - 1)
		pages.append(page)


func _make_page(page_index: int) -> Control:
	var page := Control.new()
	page.name = "BookPage%d" % (page_index + 1)
	page.position = Vector2(-457, -246)
	page.size = Vector2(40, 40)
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_slot(page, 0, page_index * 2)
	_build_slot(page, 1, page_index * 2 + 1)
	return page


func _build_slot(page: Control, slot: int, entry_index: int) -> void:
	if entry_index >= ENTRIES.size():
		return
	var entry: Dictionary = ENTRIES[entry_index]
	var is_left := slot == 0
	var title_x := 207.0 if is_left else 540.0
	var title_y := 38.0 if is_left else 37.0
	var logo_y := 61.0 if is_left else 66.0
	var desc_x := 187.0 if is_left else 520.0
	var desc_y := 234.0 if is_left else 233.0

	var title := Label.new()
	title.position = Vector2(title_x, title_y)
	title.size = Vector2(162, 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0, 0, 0))
	title.add_theme_font_size_override("font_size", 18)
	if _font:
		title.add_theme_font_override("font", _font)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.text = str(entry["title"])
	page.add_child(title)

	var logo := TextureRect.new()
	logo.position = Vector2(title_x, logo_y)
	logo.size = Vector2(162, 165)
	logo.texture = _make_atlas(str(entry["sheet"]))
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(logo)

	var desc := Label.new()
	desc.position = Vector2(desc_x, desc_y)
	desc.size = Vector2(208, 110)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	desc.add_theme_color_override("font_color", Color(0, 0, 0))
	desc.add_theme_font_size_override("font_size", 13)
	if _font:
		desc.add_theme_font_override("font", _font)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.text = str(entry["desc"])
	page.add_child(desc)


func _make_atlas(sheet_path: String) -> Texture2D:
	var tex := load(sheet_path) as Texture2D
	if tex == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(0, 0, FRAME_SIZE, FRAME_SIZE)
	return atlas


func update_page_visibility() -> void:
	if pages.is_empty():
		return
	current_page_index = clampi(current_page_index, 0, pages.size() - 1)
	for i in range(pages.size()):
		pages[i].visible = (i == current_page_index)


func _on_next_button_pressed() -> void:
	if pages.size() <= 1:
		return
	if paper_sound and paper_sound.stream:
		paper_sound.play()
	current_page_index = (current_page_index + 1) % pages.size()
	update_page_visibility()


func _on_close_button_pressed() -> void:
	visible = false
	closed.emit()
