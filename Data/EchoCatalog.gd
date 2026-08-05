class_name EchoCatalog
extends RefCounted

# Katalog statis 6 emosi (Section 11 GDD).
# Data ini murni panduan — tidak membocorkan stabilitas tersembunyi pasien.

const ENTRIES: Dictionary = {
	Emotion.Type.FEAR: {
		"name": "Echo Retak",
		"emotion": "Ketakutan",
		"visual": "Retakan tipis menjalar di permukaan kabut. Echo bergetar kecil dan cenderung menjauh dari pasien.",
		"body": "Tangan menggenggam, bahu naik, mata sering melirik ke pintu.",
		"dialog": "Kalimat terpotong, sering 'saya tidak tahu', nada naik di akhir kalimat.",
		"clue": "Retakan + echo yang mundur menjauh dari topik adalah penanda paling kuat.",
	},
	Emotion.Type.ANGER: {
		"name": "Echo Api",
		"emotion": "Kemarahan",
		"visual": "Percikan api kecil di tepi kabut, warna memerah dari dalam. Echo membesar dan mendekat.",
		"body": "Rahang mengeras, tangan mengepal, tubuh condong ke depan.",
		"dialog": "Kalimat pendek dan tegas, menyalahkan pihak lain.",
		"clue": "Api + echo yang mendekat ke arah Anda.",
	},
	Emotion.Type.SADNESS: {
		"name": "Echo Akar",
		"emotion": "Kesedihan",
		"visual": "Akar atau rantai tipis menjuntai ke bawah. Echo tampak berat dan turun mendekati lantai.",
		"body": "Bahu turun, kepala menunduk, gerakan lamban.",
		"dialog": "Kalimat panjang tanpa kesimpulan, sering mengulang nama dari masa lalu.",
		"clue": "Akar menjuntai + echo yang turun adalah penanda kuat.",
	},
	Emotion.Type.GUILT: {
		"name": "Echo Mata",
		"emotion": "Rasa Bersalah",
		"visual": "Mata-mata kecil muncul di permukaan kabut, semuanya menghadap ke arah pasien sendiri.",
		"body": "Menghindari kontak mata, tangan meremas-remas.",
		"dialog": "Permintaan maaf berulang, kalimat penyesalan atas tindakan spesifik.",
		"clue": "Mata yang menghadap pasien sendiri, bukan ke luar.",
	},
	Emotion.Type.SHAME: {
		"name": "Echo Lipat",
		"emotion": "Rasa Malu",
		"visual": "Echo melipat ke dalam dan menyembunyikan diri di balik tubuh pasien.",
		"body": "Tubuh membungkuk, tangan menutupi sebagian wajah.",
		"dialog": "Menyalahkan diri sendiri secara umum, enggan menjelaskan detail.",
		"clue": "Echo yang bersembunyi secara fisik di balik pasien.",
	},
	Emotion.Type.ENVY: {
		"name": "Echo Bayangan Kembar",
		"emotion": "Kecemburuan",
		"visual": "Kabut membelah menjadi dua siluet; satu condong meniru arah pihak yang dibicarakan.",
		"body": "Melirik ke samping, senyum tipis yang tidak tulus saat memuji orang lain.",
		"dialog": "Sering membandingkan diri dengan orang lain.",
		"clue": "Pembelahan echo menjadi dua siluet adalah ciri unik.",
	},
}

const ORDER: Array = [
	Emotion.Type.FEAR,
	Emotion.Type.ANGER,
	Emotion.Type.SADNESS,
	Emotion.Type.GUILT,
	Emotion.Type.SHAME,
	Emotion.Type.ENVY,
]


static func get_entry(emotion: Emotion.Type) -> Dictionary:
	return ENTRIES.get(emotion, {})


static func all() -> Array:
	var result := []
	for emotion in ORDER:
		result.append(ENTRIES[emotion])
	return result
