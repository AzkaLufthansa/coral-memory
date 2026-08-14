extends Control

signal file_closed

@onready var name_label: Label = %NameLabel
@onready var usia_label: Label = %UsiaLabel
@onready var visits_label: Label = %VisitsLabel
@onready var job_label: Label = %PekerjaanLabel
@onready var rujukan_label: Label = %RujukanLabel
@onready var day_label: Label = %DayLabel
@onready var session_label: Label = %SessionLabel
@onready var remaining_label: Label = %RemainingLabel
@onready var notes_label: Label = %NotesLabel

# --- NODE PATH JADWAL ---
@onready var page1: Control = %ScheduleContent.get_node("Page1")
@onready var page2: Control = %ScheduleContent.get_node("Page2")
@onready var left_arrow: Button = page2.get_node("LeftArrowButton")
@onready var right_arrow: Button = %ScheduleContent.get_node("RightArrowButton")


@onready var patient_info_elements: Array = [
	name_label, usia_label, job_label, rujukan_label, 
	visits_label, notes_label, $Logo]


func _ready() -> void:
	if not %CloseButton.pressed.is_connected(_on_close_button_pressed):
		%CloseButton.pressed.connect(_on_close_button_pressed)
		
	if not $ScheduleButton.pressed.is_connected(_on_schedule_button_pressed):
		$ScheduleButton.pressed.connect(_on_schedule_button_pressed)
		
	if not $PatientButton.pressed.is_connected(_on_patient_button_pressed):
		$PatientButton.pressed.connect(_on_patient_button_pressed)
	
	if not left_arrow.pressed.is_connected(_on_left_arrow_pressed):
		left_arrow.pressed.connect(_on_left_arrow_pressed)
		
	if not right_arrow.pressed.is_connected(_on_right_arrow_pressed):
		right_arrow.pressed.connect(_on_right_arrow_pressed)


func show_patient(patient: PatientData) -> void:
	name_label.text = "Nama: %s" % patient.display_name
	usia_label.text = "Usia: %d" % [patient.age]
	job_label.text = "Pekerjaan: %s" % [patient.profession]
	rujukan_label.text = "Alasan Rujukan: %s" % [patient.referral_reason]
	
	var visit_count := patient.diagnosis_history.size()
	var visit_text := str(visit_count) if visit_count > 0 else "Pasien baru (belum pernah diperiksa)"
	visits_label.text = "Kunjungan Sebelumnya: %s" % visit_text
	
	day_label.text = "HARI %d / %d" % [EchoManager.day, GameConfig.DAYS_TOTAL]
	session_label.text = "SESI %d / %d" % [EchoManager.session_index, GameConfig.SESSIONS_PER_DAY]
	remaining_label.text = "Pertanyaan tersisa: %d" % EchoManager.get_topics_remaining()

	var prev_echo := "-"
	if not patient.diagnosis_history.is_empty():
		var last: Dictionary = patient.diagnosis_history[-1]
		prev_echo = Emotion.display_name(last["chosen_emotion"])
	
	# --- RESET TAMPILAN AWAL SAAT BERKAS DIBUKA ---
	# 1. Pastikan selalu membuka tab Informasi Pasien
	_show_patient_tab()
	
	# 2. Pastikan jadwal selalu mulai dari Halaman 1
	page1.show()
	page2.hide() # Otomatis menyembunyikan left_arrow juga
	right_arrow.show()
	
	visible = true


func _on_close() -> void:
	visible = false
	file_closed.emit()


func _on_close_button_pressed() -> void:
	_play_click()
	_on_close()


# --- FUNGSI TAB ---

func _on_schedule_button_pressed() -> void:
	_play_click()
	%ScheduleContent.show()
	$Monitor2.hide() # Sembunyikan monitor utama
	# Sembunyikan elemen informasi pasien satu per satu
	for element in patient_info_elements:
		if element:
			element.hide()


func _on_patient_button_pressed() -> void:
	_play_click()
	_show_patient_tab()


func _show_patient_tab() -> void:
	%ScheduleContent.hide()
	$Monitor2.show() # Tampilkan kembali monitor utama
	# Tampilkan kembali elemen informasi pasien
	for element in patient_info_elements:
		if element:
			element.show()


# --- FUNGSI NAVIGASI JADWAL (PAGINASI) ---

func _on_right_arrow_pressed() -> void:
	_play_click()
	page1.hide()
	page2.show() # Otomatis menampilkan left_arrow
	right_arrow.hide()


func _on_left_arrow_pressed() -> void:
	_play_click()
	page2.hide() # Otomatis menyembunyikan left_arrow
	page1.show()
	right_arrow.show()


# Fungsi helper untuk suara klik agar aman jika node Click tidak sengaja terhapus
func _play_click() -> void:
	if has_node("Click"):
		$Click.play()
