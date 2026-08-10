extends PanelContainer

signal file_closed

@onready var name_label: Label = %NameLabel
@onready var detail_label: Label = %DetailLabel
@onready var visits_label: Label = %VisitsLabel
@onready var prev_echo_label: Label = %PrevEchoLabel
@onready var notes_label: Label = %NotesLabel


func _ready() -> void:
	%CloseButton.pressed.connect(func() -> void: file_closed.emit())


func show_patient(patient: PatientData) -> void:
	name_label.text = patient.display_name
	detail_label.text = "Usia: %d\nPekerjaan: %s\nAlasan Rujukan: %s" % [
		patient.age, patient.profession, patient.referral_reason
	]
	var visit_count := patient.diagnosis_history.size()
	var visit_text := str(visit_count) if visit_count > 0 else "Pasien baru (belum pernah diperiksa)"
	visits_label.text = "Kunjungan Sebelumnya: %s" % visit_text

	var prev_echo := "-"
	if not patient.diagnosis_history.is_empty():
		var last: Dictionary = patient.diagnosis_history[-1]
		prev_echo = Emotion.display_name(last["chosen_emotion"])
	prev_echo_label.text = "Core Echo Sebelumnya: %s" % prev_echo

	notes_label.text = "Catatan: -"
	visible = true


func _on_close() -> void:
	visible = false
	file_closed.emit()


func _on_close_button_pressed():
	$Click.play()
