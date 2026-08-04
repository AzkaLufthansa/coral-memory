class_name GameConfig
extends RefCounted

enum Schedule { BESOK, DUA_HARI, TIGA_HARI }

const DAYS_TOTAL := 7
const SESSIONS_PER_DAY := 5
const MAX_TOPICS_PER_SESSION := 3

# Section 16 / 38
const RECOVERY_BONUS := 15
const MAX_STABILITY := 100
const MIN_STABILITY := 0
const MIN_DECAY_PER_DAY := 0

# Section 38.2
const SCHEDULE_DAYS: Dictionary = {
	Schedule.BESOK: 1,
	Schedule.DUA_HARI: 2,
	Schedule.TIGA_HARI: 3,
}

const SCHEDULE_TOLERANCE_DEFAULT: Dictionary = {
	Schedule.BESOK: 20,
	Schedule.DUA_HARI: 10,
	Schedule.TIGA_HARI: 5,
}

const SCHEDULE_LABELS: Dictionary = {
	Schedule.BESOK: "Besok (+1 hari)",
	Schedule.DUA_HARI: "2 Hari Lagi (+2)",
	Schedule.TIGA_HARI: "3 Hari Lagi (+3)",
}

# Section 30 ranges
const STABILITY_MIN := 40
const STABILITY_MAX := 70
const DECAY_RATE_MIN := 5
const DECAY_RATE_MAX := 15
const MISDIAGNOSIS_PENALTY_MIN := 20
const MISDIAGNOSIS_PENALTY_MAX := 30

# Section 38.1: template default topik -> emosi (Primary/Secondary)
const TOPIC_PRIMARY_TEMPLATE: Dictionary = {
	Emotion.Type.FEAR: [Topic.Name.MASA_LALU, Topic.Name.PEKERJAAN],
	Emotion.Type.ANGER: [Topic.Name.PEKERJAAN, Topic.Name.HUBUNGAN],
	Emotion.Type.SADNESS: [Topic.Name.MASA_LALU, Topic.Name.KELUARGA],
	Emotion.Type.GUILT: [Topic.Name.PENYESALAN, Topic.Name.MASA_LALU],
	Emotion.Type.SHAME: [Topic.Name.PENYESALAN, Topic.Name.MASA_DEPAN],
	Emotion.Type.ENVY: [Topic.Name.HUBUNGAN, Topic.Name.MASA_DEPAN],
}

const TOPIC_SECONDARY_TEMPLATE: Dictionary = {
	Emotion.Type.FEAR: [Topic.Name.HUBUNGAN, Topic.Name.MASA_DEPAN],
	Emotion.Type.ANGER: [Topic.Name.MASA_LALU, Topic.Name.PENYESALAN],
	Emotion.Type.SADNESS: [Topic.Name.HUBUNGAN, Topic.Name.PENYESALAN],
	Emotion.Type.GUILT: [Topic.Name.KELUARGA, Topic.Name.PEKERJAAN],
	Emotion.Type.SHAME: [Topic.Name.KELUARGA, Topic.Name.HUBUNGAN],
	Emotion.Type.ENVY: [Topic.Name.PEKERJAAN, Topic.Name.MASA_LALU],
}

static func schedule_label(schedule: Schedule) -> String:
	return SCHEDULE_LABELS[schedule]

static func schedule_days(schedule: Schedule) -> int:
	return SCHEDULE_DAYS[schedule]
