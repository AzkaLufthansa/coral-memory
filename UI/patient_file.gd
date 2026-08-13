extends PanelContainer

signal file_closed

@onready var name_label: Label = %NameLabel
@onready var usia_label: Label = %UsiaLabel
@onready var visits_label: Label = %VisitsLabel
@onready var job_label: Label = %PekerjaanLabel
@onready var rujukan_label: Label = %RujukanLabel
@onready var day_label: Label = %DayLabel
@onready var session_label: Label = %SessionLabel
@onready var remaining_label: Label = %RemainingLabel

# Node navigasi jadwal (Diambil berdasarkan path karena belum menggunakan tanda %)
@onready var page1: GridContainer = %ScheduleContent.get_node("MarginContainer/Page1")
@onready var page2: GridContainer = %ScheduleContent.get_node("MarginContainer/Page2")
@onready var left_arrow: Button = %ScheduleContent.get_node("LeftArrowButton")
@onready var right_arrow: Button = %ScheduleContent.get_node("RightArrowButton")


func _ready() -> void:
	%CloseButton.pressed.connect(func() -> void: file_closed.emit())
	
	# Hubungkan sinyal panah kiri dan kanan (jika belum dihubungkan via editor UI)
	left_arrow.pressed.connect(_on_left_arrow_pressed)
	right_arrow.pressed.connect(_on_right_arrow_pressed)


func show_patient(patient: PatientData) -> void:
	name_label.text = "Nama: %s\n" % patient.display_name
	usia_label.text = "Usia: %d\n" % [patient.age]
	job_label.text = "Pekerjaan: %s\n" % [patient.profession]
	rujukan_label.text = "Alasan Rujukan: %s\n" % [patient.referral_reason]
	
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
	%PatientContent.show()
	%ScheduleContent.hide()
	
	# 2. Pastikan jadwal selalu mulai dari Halaman 1
	page1.show()
	page2.hide()
	left_arrow.hide() # Sembunyikan panah kiri karena di awal (hal 1) tidak bisa mundur
	right_arrow.show()
	
	visible = true


func _on_close() -> void:
	visible = false
	file_closed.emit()


func _on_close_button_pressed() -> void:
	$Click.play()
	_on_close()


# --- FUNGSI TAB ---

func _on_schedule_button_pressed() -> void:
	$Click.play()
	%ScheduleContent.show()
	%PatientContent.hide() # Menyembunyikan Info Pasien


func _on_patient_button_pressed() -> void:
	$Click.play()
	%PatientContent.show() # Menampilkan Info Pasien
	%ScheduleContent.hide()


# --- FUNGSI NAVIGASI JADWAL (PAGINASI) ---

func _on_right_arrow_pressed() -> void:
	$Click.play()
	# Pindah ke halaman 2
	page1.hide()
	page2.show()
	# Tampilkan panah kiri, sembunyikan panah kanan
	right_arrow.hide()
	left_arrow.show()


func _on_left_arrow_pressed() -> void:
	$Click.play()
	# Kembali ke halaman 1
	page2.hide()
	page1.show()
	# Sembunyikan panah kiri, tampilkan panah kanan
	left_arrow.hide()
	right_arrow.show()
