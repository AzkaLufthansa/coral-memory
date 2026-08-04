extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var detail_label: Label = %DetailLabel
@onready var referral_label: Label = %ReferralLabel
@onready var type_label: Label = %TypeLabel


func show_patient(patient: PatientData) -> void:
	name_label.text = patient.display_name
	detail_label.text = "Usia %d · %s" % [patient.age, patient.profession]
	referral_label.text = "Alasan rujukan: %s" % patient.referral_reason
	type_label.text = "PASIEN BARU" if not patient.is_control_patient else "PASIEN KONTROL"
	type_label.modulate = Color(0.6, 0.75, 0.85) if patient.is_control_patient else Color(0.9, 0.85, 0.7)
	visible = true
