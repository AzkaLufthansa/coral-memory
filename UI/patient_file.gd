extends Control

signal file_closed
signal decision_submitted(emotion: Emotion.Type, schedule: GameConfig.Schedule)

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
@onready var submit_button: Button = $SubmitButton if has_node("SubmitButton") else null
@onready var title_label: Control = $PatientOverlay/Title if has_node("PatientOverlay/Title") else null
@onready var click_sfx: AudioStreamPlayer = $Click if has_node("Click") else null

# --- REFERENSI NODE JADWAL ---
@onready var schedule_content: Control = %ScheduleContent
@onready var page1: Control = %ScheduleContent/Page1
@onready var page2: Control = %ScheduleContent/Page2
@onready var left_arrow: Button = %ScheduleContent/Page2/LeftArrowButton
@onready var right_arrow: Button = %ScheduleContent/RightArrowButton

# --- REFERENSI NODE SUBMIT ---
@onready var submit_content: Control = %SubmitContent

var submit_confirm_button: Button = null
var _emotion_buttons: Dictionary = {}  # Emotion.Type -> Button
var _schedule_buttons: Dictionary = {}  # GameConfig.Schedule -> Button
var _selected_emotion: Emotion.Type = -1
var _selected_schedule: GameConfig.Schedule = -1

# --- ANIMATION PLAYER (monitor terbuka/tertutup) ---
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var monitor2: Sprite2D = $Monitor2
@onready var open_sfx: AudioStreamPlayer = $OpenSound
@onready var close_sfx: AudioStreamPlayer = $CloseSound

# Detail pasien (disembunyikan saat tab Schedule; Hari/Sesi/Sisa tetap tampil).
@onready var patient_details: Array[Control] = [
	name_label, usia_label, job_label, rujukan_label,
	visits_label, notes_label, logo
]

# Semua elemen info (untuk buka/tutup monitor secara keseluruhan).
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

	if submit_button and not submit_button.pressed.is_connected(_on_submit_button_pressed):
		submit_button.pressed.connect(_on_submit_button_pressed)

	if left_arrow and not left_arrow.pressed.is_connected(_on_left_arrow_pressed):
		left_arrow.pressed.connect(_on_left_arrow_pressed)

	if right_arrow and not right_arrow.pressed.is_connected(_on_right_arrow_pressed):
		right_arrow.pressed.connect(_on_right_arrow_pressed)

	open_sfx.stream = SfxUtil.first_available([
		"res://Assets/Audio/SFX buka lemari.mp3",
		"res://Assets/SFX/buka_monitor.mp3",
	])
	close_sfx.stream = SfxUtil.first_available([
		"res://Assets/Audio/SFX buka tutup kunci pintu.mp3",
		"res://Assets/SFX/tutup_monitor.mp3",
	])

	submit_confirm_button = $SubmitContent/SubmitButton
	submit_confirm_button.disabled = true
	_build_submit_buttons()
	submit_confirm_button.pressed.connect(_on_submit_confirm_pressed)


func show_patient(patient: PatientData) -> void:
	_populate_patient_data(patient)

	page1.show()
	page2.hide()
	right_arrow.show()

	_set_ui_content_visible(false)
	schedule_content.hide()
	submit_content.hide()
	visible = true

	await _play_open_animation()
	_show_patient_tab()


func _play_open_animation() -> void:
	monitor.visible = false
	monitor2.visible = true
	monitor2.frame = 0
	if open_sfx and open_sfx.stream:
		open_sfx.play()
	if anim_player and anim_player.has_animation("open_monitor"):
		anim_player.play("open_monitor")
		anim_player.seek(0.0, true) # KUNCI: mencegah tampilan langsung muncul utuh
		await anim_player.animation_finished
	monitor2.visible = false
	monitor.visible = true


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
	submit_content.hide()

	await _play_close_animation()

	visible = false
	file_closed.emit()


func _play_close_animation() -> void:
	monitor.visible = false
	monitor2.visible = true
	monitor2.frame = 3
	if close_sfx and close_sfx.stream:
		close_sfx.play()
	if anim_player and anim_player.has_animation("close_monitor"):
		anim_player.play("close_monitor")
		anim_player.seek(0.0, true)
		await anim_player.animation_finished
	monitor2.visible = false
	monitor.visible = true


func _on_close_button_pressed() -> void:
	_play_click()
	_on_close()


# --- FUNGSI TAB ---

func _on_schedule_button_pressed() -> void:
	_play_click()
	submit_content.hide()
	schedule_content.show()
	for element in patient_details:
		if element:
			element.hide()


func _on_patient_button_pressed() -> void:
	_play_click()
	_show_patient_tab()


func _on_submit_button_pressed() -> void:
	_play_click()
	_reset_submit_selection()
	schedule_content.hide()
	submit_content.show()
	for element in patient_details:
		if element:
			element.hide()


func _build_submit_buttons() -> void:
	_emotion_buttons[Emotion.Type.FEAR] = $SubmitContent/KetakutanButton
	_emotion_buttons[Emotion.Type.ANGER] = $SubmitContent/KemarahanButton
	_emotion_buttons[Emotion.Type.SADNESS] = $SubmitContent/KesedihanButton
	_emotion_buttons[Emotion.Type.GUILT] = $SubmitContent/RasaBersalahButton
	_emotion_buttons[Emotion.Type.SHAME] = $SubmitContent/RasaMaluButton
	_emotion_buttons[Emotion.Type.ENVY] = $SubmitContent/KedengkianButton
	for emotion in _emotion_buttons:
		var button: Button = _emotion_buttons[emotion]
		button.toggle_mode = true
		button.toggled.connect(_on_emotion_toggled.bind(emotion))
	_emotion_buttons[Emotion.Type.ANGER].text = "Kemarahan" # bersihkan newline bawaan editor

	_schedule_buttons[GameConfig.Schedule.BESOK] = $SubmitContent/BesokButton
	_schedule_buttons[GameConfig.Schedule.DUA_HARI] = $SubmitContent/LusaButton
	_schedule_buttons[GameConfig.Schedule.TIGA_HARI] = $SubmitContent/TigaHariButton
	_schedule_buttons[GameConfig.Schedule.TIGA_HARI].text = "Tiga Hari" # perbaiki salah tulis "Lusa"
	for schedule in _schedule_buttons:
		var button: Button = _schedule_buttons[schedule]
		button.toggle_mode = true
		button.toggled.connect(_on_schedule_toggled.bind(schedule))


func _reset_submit_selection() -> void:
	_selected_emotion = -1
	_selected_schedule = -1
	for button in _emotion_buttons.values():
		button.set_pressed_no_signal(false)
	for button in _schedule_buttons.values():
		button.set_pressed_no_signal(false)
	submit_confirm_button.disabled = true


func _on_emotion_toggled(pressed: bool, emotion: Emotion.Type) -> void:
	if pressed:
		_selected_emotion = emotion
		for other in _emotion_buttons:
			if other != emotion:
				_emotion_buttons[other].set_pressed_no_signal(false)
	else:
		if _selected_emotion == emotion:
			_selected_emotion = -1
	_update_submit_confirm()


func _on_schedule_toggled(pressed: bool, schedule: GameConfig.Schedule) -> void:
	if pressed:
		_selected_schedule = schedule
		for other in _schedule_buttons:
			if other != schedule:
				_schedule_buttons[other].set_pressed_no_signal(false)
	else:
		if _selected_schedule == schedule:
			_selected_schedule = -1
	_update_submit_confirm()


func _update_submit_confirm() -> void:
	submit_confirm_button.disabled = _selected_emotion == -1 or _selected_schedule == -1


func _on_submit_confirm_pressed() -> void:
	if _selected_emotion == -1 or _selected_schedule == -1:
		return
	_play_click()
	decision_submitted.emit(_selected_emotion, _selected_schedule)
	_on_close()


func _show_patient_tab() -> void:
	schedule_content.hide()
	submit_content.hide()
	_set_ui_content_visible(true)


func _set_ui_content_visible(is_show: bool) -> void:
	for element in patient_info_elements:
		if element:
			element.visible = is_show

	if patient_button: patient_button.visible = is_show
	if schedule_button: schedule_button.visible = is_show
	if submit_button: submit_button.visible = is_show
	if close_button: close_button.visible = is_show
	if title_label: title_label.visible = is_show


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
