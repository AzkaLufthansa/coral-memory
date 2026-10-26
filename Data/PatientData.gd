class_name PatientData
extends Resource

# Identitas (Section 28)
@export var npc_instance_id: String = ""
@export var base_npc_id: String = "NPC-A"
@export var sprite_id: String = "" 
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
@export var is_diagnosed: bool = false
@export var echo_transformed: bool = false
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
	if (is_diagnosed or topic == Topic.Name.KABAR) and not dialog_lines.has(topic):
		return get_checkup_dialog()
	return dialog_lines.get(topic, "")


func get_checkup_dialog() -> String:
	if base_npc_id.to_upper().strip_edges() == "NPC-H":
		return "Meow... (tampak lebih tenang dan mendengkur pelan)."
	match true_emotion:
		Emotion.Type.FEAR:
			return "Keadaanku sudah jauh lebih tenang. Ketakutan itu masih ada sesekali, tapi aku mulai bisa menghadapinya."
		Emotion.Type.ANGER:
			return "Nafasku sudah tidak seberat dulu. Aku berusaha tidak membiarkan amarah itu mengendalikanku lagi."
		Emotion.Type.SADNESS:
			return "Rumah masih terasa sunyi, tapi aku mulai bisa melangkah lagi hari ini. Terima kasih."
		Emotion.Type.GUILT:
			return "Beban di dadaku rasanya sedikit berkurang. Aku sedang berusaha berdamai dengan masa lalu."
		Emotion.Type.SHAME:
			return "Aku mencoba untuk tidak terlalu keras pada diriku sendiri. Perlahan, aku merasa lebih berharga."
		Emotion.Type.ENVY:
			return "Aku mulai belajar fokus pada perjalananku sendiri, bukan orang lain. Rasanya jauh lebih melegakan."
		_:
			return "Keadaanku jauh lebih baik sekarang. Terima kasih atas bantuanmu."
