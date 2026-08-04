class_name Emotion
extends RefCounted

enum Type { FEAR, ANGER, SADNESS, GUILT, SHAME, ENVY }

const DISPLAY_NAMES: Dictionary = {
	Type.FEAR: "Ketakutan",
	Type.ANGER: "Kemarahan",
	Type.SADNESS: "Kesedihan",
	Type.GUILT: "Rasa Bersalah",
	Type.SHAME: "Rasa Malu",
	Type.ENVY: "Kecemburuan",
}

const ECHO_NAMES: Dictionary = {
	Type.FEAR: "Echo Retak",
	Type.ANGER: "Echo Api",
	Type.SADNESS: "Echo Akar",
	Type.GUILT: "Echo Mata",
	Type.SHAME: "Echo Lipat",
	Type.ENVY: "Echo Bayangan Kembar",
}

const ACCENT_COLORS: Dictionary = {
	Type.FEAR: Color(0.75, 0.8, 0.9),
	Type.ANGER: Color(0.95, 0.45, 0.2),
	Type.SADNESS: Color(0.4, 0.55, 0.75),
	Type.GUILT: Color(0.9, 0.85, 0.6),
	Type.SHAME: Color(0.6, 0.5, 0.65),
	Type.ENVY: Color(0.5, 0.7, 0.5),
}

static func display_name(type: Type) -> String:
	return DISPLAY_NAMES[type]

static func echo_name(type: Type) -> String:
	return ECHO_NAMES[type]
