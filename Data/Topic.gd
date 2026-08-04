class_name Topic
extends RefCounted

enum Name { KELUARGA, PEKERJAAN, HUBUNGAN, MASA_LALU, PENYESALAN, MASA_DEPAN }

enum Relevance { PRIMARY, SECONDARY, NEUTRAL, DEFLECTIVE }

const DISPLAY_NAMES: Dictionary = {
	Name.KELUARGA: "Keluarga",
	Name.PEKERJAAN: "Pekerjaan",
	Name.HUBUNGAN: "Hubungan",
	Name.MASA_LALU: "Masa Lalu",
	Name.PENYESALAN: "Penyesalan",
	Name.MASA_DEPAN: "Masa Depan",
}

const ALL_TOPICS: Array = [
	Name.KELUARGA,
	Name.PEKERJAAN,
	Name.HUBUNGAN,
	Name.MASA_LALU,
	Name.PENYESALAN,
	Name.MASA_DEPAN,
]

static func display_name(name: Name) -> String:
	return DISPLAY_NAMES[name]
