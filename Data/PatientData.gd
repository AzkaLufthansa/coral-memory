class_name PatientData
extends Resource

# Identitas (Section 28)
@export var npc_instance_id: String = ""
@export var base_npc_id: String = "NPC-A"
@export var display_name: String = ""
@export var age: int = 30
@export var profession: String = ""
@export var referral_reason: String = ""

# Variabel tersembunyi (Section 16)
@export var true_emotion: Emotion.Type = Emotion.Type.FEAR
@export var secondary_emotion: Emotion.Type = -1
@export var stability: int = 60
@export var decay_rate: int = 10
@export var misdiagnosis_penalty: int = 25

# Topic.Name -> Topic.Relevance (Section 15/28)
var topic_relevance_map: Dictionary = {}

# Topic.Name -> String (Section 13)
var dialog_lines: Dictionary = {}

# GameConfig.Schedule -> int (Section 16)
var schedule_tolerance_map: Dictionary = {}

# State kontrol
var is_control_patient: bool = false
var next_checkup_day: int = -1
var pending_decay_per_day: int = 0
var diagnosis_history: Array = []

# State investigasi sesi berjalan
var topics_used: Array = []


func reset_session_state() -> void:
	topics_used = []


func get_relevance(topic: Topic.Name) -> Topic.Relevance:
	return topic_relevance_map.get(topic, Topic.Relevance.NEUTRAL)


func get_dialog(topic: Topic.Name) -> String:
	return dialog_lines.get(topic, "")
