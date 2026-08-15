extends Control

signal file_closed

# --- REFERENSI NODE LABELS PASIEN ---
@onready var name_label: Label = %NameLabel
@onready var usia_label: Label = %UsiaLabel
@onready var visits_label: Label = %VisitsLabel
@onready var job_label: Label = %PekerjaanLabel
@onready var rujukan_label: Label = %RujukanLabel
@onready var day_label: Label = %DayLabel
@onready var session_label: Label = %SessionLabel
@onready var remaining_label: Label = %RemainingLabel
@onready var notes_label: Label = %NotesLabel
@onready var monitor: TextureRect = $PatientOverlay/Monitor
@onready var logo: TextureRect = $PatientOverlay/Logo

# --- REFERENSI NODE TOMBOL & UI UTAMA ---
@onready var close_button: Button = %CloseButton
@onready var schedule_button: Button = $ScheduleButton if has_node("ScheduleButton") else null
@onready var patient_button: Button = $PatientButton if has_node("PatientButton") else null
@onready var title_label: Control = $PatientOverlay/Title if has_node("PatientOverlay/Title") else null
@onready var click_sfx: AudioStreamPlayer = $Click if has_node("Click") else null

# --- REFERENSI NODE JADWAL ---
@onready var schedule_content: Control = %ScheduleContent
@onready var page1: Control = %ScheduleContent/Page1
@onready var page2: Control = %ScheduleContent/Page2
@onready var left_arrow: Button = %ScheduleContent/Page2/LeftArrowButton
@onready var right_arrow: Button = %ScheduleContent/RightArrowButton

# --- ANIMATION PLAYER ---
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# --- KELOMPOK ELEMEN INFO PASIEN (Teks, Judul & Logo) ---
@onready var patient_info_elements: Array[Control] = [
	name_label, usia_label, job_label, rujukan_label, 
	visits_label, day_label, session_label, remaining_label, 
	notes_label, logo
]


func _ready() -> void:
	if close_button and not close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)
		
	if schedule_button and not schedule_button.pressed.is_connected(_on_schedule_button_pressed):
		schedule_button.pressed.connect(_on_schedule_button_pressed)
		
	if patient_button and not patient_button.pressed.is_connected(_on_patient_button_pressed):
		patient_button.pressed.connect(_on_patient_button_pressed)
		
	if left_arrow and not left_arrow.pressed.is_connected(_on_left_arrow_pressed):
		left_arrow.pressed.connect(_on_left_arrow_pressed)
		
	if right_arrow and not right_arrow.pressed.is_connected(_on_right_arrow_pressed):
		right_arrow.pressed.connect(_on_right_arrow_pressed)


func show_patient(patient: PatientData) -> void:
	# 1. Isi data teks pasien terlebih dahulu
	_populate_patient_data(patient)
	
	# 2. Reset tampilan halaman jadwal
	page1.show()
	page2.hide()
	right_arrow.show()
	
	# 3. Sembunyikan semua teks, logo, judul & tombol SEBELUM animasi berjalan
	_set_ui_content_visible(false)
	schedule_content.hide()
	
	# 4. Aktifkan root node
	visible = true
	
	# 5. Mainkan animasi & PAKSA mundur ke Frame 0 seketika itu juga
	if anim_player and anim_player.has_animation("open_monitor"):
		anim_player.play("open_monitor")
		anim_player.seek(0, true) # <--- KUNCI PERBAIKAN: Mencegah tampilan berkedip/langsung muncul utuh
		await anim_player.animation_finished
	
	# 6. Tampilkan teks, logo & judul SETELAH animasi selesai
	_show_patient_tab()


func _populate_patient_data(patient: PatientData) -> void:
	name_label.text = "Nama: %s" % patient.display_name
	usia_label.text = "Usia: %d" % patient.age
	job_label.text = "Pekerjaan: %s" % patient.profession
	rujukan_label.text = "Alasan Rujukan: %s" % patient.referral_reason
	
	if "notes" in patient:
		notes_label.text = "Catatan: %s" % patient.notes
	
	var visit_count := patient.diagnosis_history.size()
	var visit_text := str(visit_count) if visit_count > 0 else "Pasien baru (belum pernah diperiksa)"
	visits_label.text = "Kunjungan Sebelumnya: %s" % visit_text
	
	day_label.text = "HARI %d / %d" % [EchoManager.day, GameConfig.DAYS_TOTAL]
	session_label.text = "SESI %d / %d" % [EchoManager.session_index, GameConfig.SESSIONS_PER_DAY]
	remaining_label.text = "Pertanyaan tersisa: %d" % EchoManager.get_topics_remaining()


func _on_close() -> void:
	_set_ui_content_visible(false)
	schedule_content.hide()
	
	if anim_player and anim_player.has_animation("close_monitor"):
		anim_player.play("close_monitor")
		anim_player.seek(0, true)
		await anim_player.animation_finished
		
	visible = false
	file_closed.emit()


func _on_close_button_pressed() -> void:
	_play_click()
	_on_close()


# --- FUNGSI TAB ---

func _on_schedule_button_pressed() -> void:
	_play_click()
	schedule_content.show()
	for element in patient_info_elements:
		if element:
			element.hide()


func _on_patient_button_pressed() -> void:
	_play_click()
	_show_patient_tab()


func _show_patient_tab() -> void:
	schedule_content.hide()
	_set_ui_content_visible(true)


func _set_ui_content_visible(is_show: bool) -> void:
	for element in patient_info_elements:
		if element:
			element.visible = is_show
	
	if patient_button: patient_button.visible = is_show
	if schedule_button: schedule_button.visible = is_show
	if close_button: close_button.visible = is_show
	if title_label: title_label.visible = is_show


# --- FUNGSI NAVIGASI JADWAL (PAGINASI) ---

func _on_right_arrow_pressed() -> void:
	_play_click()
	page1.hide()
	page2.show()
	right_arrow.hide()


func _on_left_arrow_pressed() -> void:
	_play_click()
	page2.hide()
	page1.show()
	right_arrow.show()


func _play_click() -> void:
	if click_sfx:
		click_sfx.play()
