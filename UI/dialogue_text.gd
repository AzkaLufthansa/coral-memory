extends PanelContainer

@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: Label = %TextLabel


func show_dialogue(patient: PatientData, topic: Topic.Name) -> void:
	speaker_label.text = patient.display_name
	text_label.text = patient.get_dialog(topic)
	visible = true
