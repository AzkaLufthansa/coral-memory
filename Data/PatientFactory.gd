class_name PatientFactory
extends RefCounted

static var _rng := RandomNumberGenerator.new()

const BASE_NPC_POOLS: Array[Dictionary] = [
	{"base": "NPC-A", "names": ["Dimas", "Rara", "Bima", "Maya"], "professions": ["karyawan magang", "mahasiswa", "kurir"], "referrals": ["dirujuk setelah kecelakaan ringan di tempat kerja", "laporan keluarga soal perubahan perilaku"]},
	{"base": "NPC-B", "names": ["Hendra", "Santi", "Bagus", "Linda"], "professions": ["manajer", "guru", "birokrat"], "referrals": ["keluhan atasan tentang performa kerja", "dirujuk oleh klinik rutin tahunan"]},
	{"base": "NPC-C", "names": ["Joko", "Eka", "Udin", "Sri"], "professions": ["buruh", "sopir", "teknisi"], "referrals": ["insiden keselamatan di lapangan", "dirujuk karena sering izin mendadak"]},
	{"base": "NPC-D", "names": ["Pak Marno", "Bu Ratna", "Pak Slamet", "Bu Wati"], "professions": ["pensiunan", "orang tua tunggal"], "referrals": ["perubahan drastis setelah kehilangan anggota keluarga", "laporan tetangga soal kondisi rumah"]},
	{"base": "NPC-E", "names": ["Andi", "Vina", "Rio", "Dita"], "professions": ["freelancer", "seniman", "perawat"], "referrals": ["rekan kerja melihat tanda-tanda kurang tidur", "dirujuk oleh komunitas seni"]},
	{"base": "NPC-F", "names": ["Bapak Hasan", "Ibu Nia", "Pak Gatot", "Bu Ina"], "professions": ["petugas keamanan", "atasan divisi", "pejabat dinas"], "referrals": ["dirujuk setelah insiden di ruang rapat", "observasi internal fasilitas"]},
]

# Templat dialog per emosi per topik. TIDAK menyebut nama emosi secara eksplisit.
const DIALOG_TEMPLATES: Dictionary = {
	Emotion.Type.FEAR: {
		Topic.Name.KELUARGA: "Mereka terus menelpon. Aku ... aku belum berani angkat. Takut ada apa-apa, atau malah takut tidak ada apa-apa.",
		Topic.Name.PEKERJAAN: "Aku belum bisa kembali ke sana. Setiap mendekati gedung itu, tanganku gemetar. Aku takut hal itu terulang.",
		Topic.Name.HUBUNGAN: "Temanku mengajak bertemu, tapi aku selalu mencari alasan. Aku takut mereka tanya hal-hal yang tidak ingin kusinggung.",
		Topic.Name.MASA_LALU: "Waktu itu terjadi begitu cepat. Sejak itu aku selalu menoleh ke belakang, memastikan tidak ada yang menyusul.",
		Topic.Name.PENYESALAN: "Mungkin sebaiknya kita bicarakan yang lain saja. Aku tidak ingin mengingat bagian itu.",
		Topic.Name.MASA_DEPAN: "Besok? Aku tidak tahu. Aku bahkan tidak yakin berani meninggalkan rumah.",
	},
	Emotion.Type.ANGER: {
		Topic.Name.KELUARGA: "Mereka selalu mengatur hidupku! Sudah kubilang berulang kali, tapi tidak pernah didengar. Aku muak.",
		Topic.Name.PEKERJAAN: "Bos itu menyalahkan semua orang kecuali dirinya sendiri! Laporan kemarin bukan salahku, tapi aku yang kena damprat.",
		Topic.Name.HUBUNGAN: "Orang-orang di sekitarku itu munafik semua. Tersenyum di depan, menusuk di belakang. Aku tidak tahan.",
		Topic.Name.MASA_LALU: "Jangan tanya soal masa lalu. Itu semua salah mereka, dan aku sudah bosan mengingatnya.",
		Topic.Name.PENYESALAN: "Aku tidak menyesal apa pun. Semua yang kulakukan sudah benar, dan mereka yang salah. Yang harusnya malu mereka, bukan aku!",
		Topic.Name.MASA_DEPAN: "Rencana? Aku punya banyak. Tapi semua orang akan menghalangiku, seperti biasanya.",
	},
	Emotion.Type.SADNESS: {
		Topic.Name.KELUARGA: "Ibu sudah tidak ada ... dua tahun lalu. Rumah terasa kosong. Aku masih terbiasa menoleh ke kursi tempatnya duduk.",
		Topic.Name.PEKERJAAN: "Mejaku masih sama. Tapi semuanya terasa berat, seperti mengangkat air. Aku tidak tahu kenapa.",
		Topic.Name.HUBUNGAN: "Mereka baik padaku. Tapi aku ... aku merasa tidak mampu membalas. Kadang aku hanya duduk dan diam.",
		Topic.Name.MASA_LALU: "Dulu kami sering ke pantai bersama. Sekarang ... ah, tidak usah. Semuanya sudah lewat.",
		Topic.Name.PENYESALAN: "Andai saja waktu itu aku lebih banyak di rumah. Mungkin ... mungkin semuanya tidak begini.",
		Topic.Name.MASA_DEPAN: "Masa depan? Aku tidak memikirkannya. Rasanya semua hari sama saja sekarang.",
	},
	Emotion.Type.GUILT: {
		Topic.Name.KELUARGA: "Mereka tidak tahu apa yang sebenarnya terjadi. Kalau tahu ... aku tidak yakin mereka bisa memaafkan.",
		Topic.Name.PEKERJAAN: "Insiden itu ... sebagian besar memang kesalahanku. Andai saja aku lebih teliti, dia tidak akan terluka.",
		Topic.Name.HUBUNGAN: "Setiap kali ada yang baik padaku, aku teringat apa yang kulakukan. Rasanya aku tidak berhak atas kebaikan itu.",
		Topic.Name.MASA_LALU: "Itu terjadi tiga tahun lalu, tapi aku masih mengulangnya setiap malam. Andai saja aku tidak mengambil jalan pintas waktu itu ...",
		Topic.Name.PENYESALAN: "Aku menyesal. Sangat menyesal. 'Maaf' saja tidak pernah cukup untuk memperbaiki apa yang sudah rusak.",
		Topic.Name.MASA_DEPAN: "Apakah aku pantas melanjutkan hidup setelah semua itu? Aku sendiri tidak yakin.",
	},
	Emotion.Type.SHAME: {
		Topic.Name.KELUARGA: "Aku sudah mengecewakan mereka. Semua harapan yang mereka tanam ... aku sia-siakan. Aku memang selalu begitu.",
		Topic.Name.PEKERJAAN: "Semua orang di kantor lebih mampu dariku. Aku hanya ... jadi beban. Mungkin lebih baik aku mengundurkan diri.",
		Topic.Name.HUBUNGAN: "Aku jarang keluar. Kalau ada yang melihatku begini, mereka pasti menertawakan. Lebih baik menyendiri.",
		Topic.Name.MASA_LALU: "Jangan tanya. Itu semua kegagalanku sendiri. Aku tidak mau mempermalukan diri lebih jauh.",
		Topic.Name.PENYESALAN: "Aku menyesal terlahir seperti ini. Apa pun yang kusentuh, selalu berantakan. Itu memang sudah takdirku.",
		Topic.Name.MASA_DEPAN: "Masa depan untuk orang sepertiku? Tidak usah dibicarakan. Aku tidak layak memikirkannya.",
	},
	Emotion.Type.ENVY: {
		Topic.Name.KELUARGA: "Adikku selalu jadi kesayangan. Lulus dengan pujian, kerja mapan ... semua orang memujinya. Aku? Tidak pernah begitu.",
		Topic.Name.PEKERJAAN: "Rekanku baru saja dipromosikan. Padahal kerjanya biasa saja. Dia hanya kebetulan dekat dengan atasan. Seharusnya itu posisiku.",
		Topic.Name.HUBUNGAN: "Teman lamaku hidupnya selalu mulus. Liburan, rumah baru, keluarga bahagia. Dibanding dia, hidupku ini apa?",
		Topic.Name.MASA_LALU: "Di sekolah dulu dia selalu menang, selalu dipuji. Sampai sekarang aku masih membandingkan diriku dengannya.",
		Topic.Name.PENYESALAN: "Andai saja aku yang mendapat kesempatan itu. Bukankah aku juga berusaha? Kenapa selalu dia yang beruntung.",
		Topic.Name.MASA_DEPAN: "Aku ingin bisa seperti mereka. Tapi sepertinya keberuntungan tidak pernah berpihak padaku.",
	},
}

const ALL_EMOTIONS: Array = [
	Emotion.Type.FEAR,
	Emotion.Type.ANGER,
	Emotion.Type.SADNESS,
	Emotion.Type.GUILT,
	Emotion.Type.SHAME,
	Emotion.Type.ENVY,
]


static func setup_rng() -> void:
	_rng.randomize()


static func generate_new_patients(count: int, day: int) -> Array[PatientData]:
	var patients: Array[PatientData] = []
	var used_emotions: Array = []
	for i in count:
		var emotion := _pick_emotion(used_emotions)
		used_emotions.append(emotion)
		patients.append(_build_patient(emotion, day, i))
	return patients


static func _pick_emotion(used: Array) -> Emotion.Type:
	var available := ALL_EMOTIONS.filter(func(e): return not used.has(e))
	if available.is_empty():
		available = ALL_EMOTIONS.duplicate()
	return available[_rng.randi_range(0, available.size() - 1)]


static func _build_patient(emotion: Emotion.Type, day: int, index: int) -> PatientData:
	var pool := BASE_NPC_POOLS[_rng.randi_range(0, BASE_NPC_POOLS.size() - 1)]
	var patient := PatientData.new()
	patient.npc_instance_id = "%s-day%d-%d" % [emotion, day, index]
	patient.base_npc_id = pool.base
	patient.display_name = pool.names[_rng.randi_range(0, pool.names.size() - 1)]
	patient.age = _rng.randi_range(22, 70)
	patient.profession = pool.professions[_rng.randi_range(0, pool.professions.size() - 1)]
	patient.referral_reason = pool.referrals[_rng.randi_range(0, pool.referrals.size() - 1)]
	patient.true_emotion = emotion
	patient.stability = _rng.randi_range(GameConfig.STABILITY_MIN, GameConfig.STABILITY_MAX)
	patient.decay_rate = _rng.randi_range(GameConfig.DECAY_RATE_MIN, GameConfig.DECAY_RATE_MAX)
	patient.misdiagnosis_penalty = _rng.randi_range(GameConfig.MISDIAGNOSIS_PENALTY_MIN, GameConfig.MISDIAGNOSIS_PENALTY_MAX)
	patient.topic_relevance_map = _generate_relevance_map(emotion)
	patient.dialog_lines = DIALOG_TEMPLATES[emotion].duplicate()
	patient.schedule_tolerance_map = GameConfig.SCHEDULE_TOLERANCE_DEFAULT.duplicate()
	return patient


static func _generate_relevance_map(emotion: Emotion.Type) -> Dictionary:
	var map: Dictionary = {}
	var primary_options: Array = GameConfig.TOPIC_PRIMARY_TEMPLATE[emotion]
	var secondary_options: Array = GameConfig.TOPIC_SECONDARY_TEMPLATE[emotion]

	# Variasi (Section 27): pilih 1 Primary, 1 Secondary dari pasangan template
	var primary_topic = primary_options[_rng.randi_range(0, primary_options.size() - 1)]
	var remaining_primary: Array = primary_options.duplicate()
	remaining_primary.erase(primary_topic)

	var secondary_pool: Array = secondary_options.duplicate()
	var secondary_topic = secondary_pool[_rng.randi_range(0, secondary_pool.size() - 1)]

	for topic in Topic.ALL_TOPICS:
		if topic == primary_topic:
			map[topic] = Topic.Relevance.PRIMARY
		elif topic == secondary_topic or remaining_primary.has(topic):
			map[topic] = Topic.Relevance.SECONDARY
		else:
			map[topic] = Topic.Relevance.NEUTRAL
	return map
