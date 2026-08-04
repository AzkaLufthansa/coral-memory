extends Control

signal restart_requested

@onready var title_label: Label = %TitleLabel
@onready var detail_label: Label = %DetailLabel
@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	restart_button.pressed.connect(func() -> void: restart_requested.emit())


func show_burst(patient: PatientData) -> void:
	title_label.text = "ECHO BURST"
	title_label.modulate = Color(0.9, 0.2, 0.2)
	detail_label.text = "%s (%s)\nEcho pasien pecah sebelum pemeriksaan kontrol tiba.\nGAME OVER — Hari %d" % [
		patient.display_name, patient.profession, EchoManager.day
	]
	visible = true


func show_ending(days: int) -> void:
	title_label.text = "HARI KE-7 SELESAI"
	title_label.modulate = Color(0.4, 0.8, 0.6)
	detail_label.text = "Tidak ada Echo Burst selama %d hari.\nSemua pasien berhasil melalui periode kontrol." % days
	visible = true
