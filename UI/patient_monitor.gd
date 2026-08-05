extends Control

signal monitor_closed

const TAB_INFO := 0
const TAB_SCHEDULE := 1

@onready var paper: TextureRect = %Paper
@onready var title_label: Label = %TitleLabel
@onready var info_panel: Control = %InfoPanel
@onready var schedule_panel: Control = %SchedulePanel
@onready var info_content: Label = %InfoContent
@onready var schedule_content: Label = %ScheduleContent
@onready var tab_info_button: Button = %TabInfoButton
@onready var tab_schedule_button: Button = %TabScheduleButton
@onready var close_button: Button = %CloseButton

var _tab := TAB_INFO


func _ready() -> void:
	tab_info_button.pressed.connect(_on_tab_info)
	tab_schedule_button.pressed.connect(_on_tab_schedule)
	close_button.pressed.connect(func() -> void: monitor_closed.emit())


func show_monitor(patient: PatientData) -> void:
	_goto(TAB_INFO)
	_refresh_info(patient)
	_refresh_schedule()
	visible = true


func hide_monitor() -> void:
	visible = false


func _goto(tab: int) -> void:
	_tab = tab
	info_panel.visible = tab == TAB_INFO
	schedule_panel.visible = tab == TAB_SCHEDULE
	tab_info_button.button_pressed = tab == TAB_INFO
	tab_schedule_button.button_pressed = tab == TAB_SCHEDULE


func _on_tab_info() -> void:
	_goto(TAB_INFO)


func _on_tab_schedule() -> void:
	_goto(TAB_SCHEDULE)


func _refresh_info(patient: PatientData) -> void:
	title_label.text = "PATIENT MONITOR — %s" % patient.display_name
	var visit_count := patient.diagnosis_history.size()
	var prev := "-"
	if not patient.diagnosis_history.is_empty():
		var last: Dictionary = patient.diagnosis_history[-1]
		prev = Emotion.display_name(last["chosen_emotion"])
	info_content.text = "Nama: %s\nUsia: %d\nPekerjaan: %s\nAlasan Rujukan: %s\n\nKunjungan Sebelumnya: %d\nCore Echo Sebelumnya: %s" % [
		patient.display_name, patient.age, patient.profession,
		patient.referral_reason, visit_count, prev
	]


func _refresh_schedule() -> void:
	title_label.text = "PATIENT MONITOR — JADWAL"
	var lines := ["Jadwal Kontrol (Hari 1-%d):" % GameConfig.DAYS_TOTAL]
	var pending := EchoManager.get_pending_checkups()
	if pending.is_empty():
		lines.append("  - Belum ada pasien terjadwal -")
	for p in pending:
		if p.next_checkup_day > 0:
			var status := "baru"
			if p.is_control_patient:
				status = "kontrol"
			lines.append("  Hari %d: %s (%s)" % [p.next_checkup_day, p.display_name, status])
	schedule_content.text = "\n".join(lines)
