class_name PatientFactory
extends RefCounted

static var _rng := RandomNumberGenerator.new()

# Kategori Sprite:
# - cat: Pasien3 khusus NPC-H
# - female: Pasien6, Pasien8 untuk NPC-A dan NPC-E
# - male: Pasien1, Pasien7, Pasien9, Pasien10, Pasien11 untuk NPC-B, NPC-C, NPC-D, NPC-F, NPC-G
const CAT_SPRITES: Array[String] = ["Pasien3"]
const FEMALE_SPRITES: Array[String] = ["Pasien6", "Pasien8"]
const MALE_SPRITES: Array[String] = [
	"Pasien1", "Pasien7", "Pasien9", "Pasien10", "Pasien11",
]

const CAT_NPC_POOLS: Array[String] = ["NPC-H"]
const FEMALE_NPC_POOLS: Array[String] = ["NPC-A", "NPC-E"]
const MALE_NPC_POOLS: Array[String] = [
	"NPC-B", "NPC-C", "NPC-D", "NPC-F", "NPC-G",
]

static var _npc_sprite_map: Dictionary = {}

static func is_cat_npc(base_npc_id: String) -> bool:
	var id := base_npc_id.to_upper().strip_edges()
	return id in CAT_NPC_POOLS

static func is_female_npc(base_npc_id: String) -> bool:
	var id := base_npc_id.to_upper().strip_edges()
	return id in FEMALE_NPC_POOLS

static func is_male_npc(base_npc_id: String) -> bool:
	var id := base_npc_id.to_upper().strip_edges()
	return id in MALE_NPC_POOLS

static func get_allowed_sprites(base_npc_id: String) -> Array[String]:
	if is_cat_npc(base_npc_id):
		return CAT_SPRITES.duplicate()
	elif is_female_npc(base_npc_id):
		return FEMALE_SPRITES.duplicate()
	return MALE_SPRITES.duplicate()

static func init_npc_sprite_mapping() -> void:
	_npc_sprite_map.clear()

	# 1. Cat: Pasien3 khusus NPC-H
	_npc_sprite_map["NPC-H"] = "Pasien3"

	# 2. Female: acak Pasien6 dan Pasien8 ke NPC-A dan NPC-E tanpa duplikasi
	var female_pool := FEMALE_SPRITES.duplicate()
	female_pool.shuffle()
	for i in range(mini(FEMALE_NPC_POOLS.size(), female_pool.size())):
		_npc_sprite_map[FEMALE_NPC_POOLS[i]] = female_pool[i]

	# 3. Male: acak Pasien1, 7, 9, 10, 11 ke NPC-B, C, D, F, G tanpa duplikasi
	var male_pool := MALE_SPRITES.duplicate()
	male_pool.shuffle()
	for i in range(mini(MALE_NPC_POOLS.size(), male_pool.size())):
		_npc_sprite_map[MALE_NPC_POOLS[i]] = male_pool[i]

static func get_sprite_for_npc(base_npc_id: String) -> String:
	if _npc_sprite_map.is_empty():
		init_npc_sprite_mapping()
	var key := base_npc_id.to_upper().strip_edges()
	return _npc_sprite_map.get(key, "Pasien1")

const BASE_NPC_POOLS: Array[Dictionary] = [
	{"base": "NPC-A", "names": ["Linda", "Rara", "Santi", "Maya"], "professions": ["karyawan magang", "mahasiswa", "dosen"], "referrals": ["kecelakaan ringan di tempat kerja", "laporan keluarga soal perubahan perilaku"]},
	{"base": "NPC-B", "names": ["Hendra", "Bima", "Bagus", "Dimas"], "professions": ["manajer", "guru", "birokrat"], "referrals": ["keluhan atasan tentang pekerjaan", "dirujuk oleh klinik langganan"]},
	{"base": "NPC-C", "names": ["Joko", "Eka", "Udin", "Slamet"], "professions": ["buruh", "sopir", "teknisi"], "referrals": ["insiden keselamatan di lapangan", "dirujuk karena sering izin mendadak"]},
	{"base": "NPC-D", "names": ["Marno", "Rio", "Andi", "Wati"], "professions": ["pensiunan", "pengangguran"], "referrals": ["perubahan setelah kehilangan anggota keluarga", "laporan tetangga soal kondisi rumah"]},
	{"base": "NPC-E", "names": ["Sri", "Vina", "Ratna", "Dita"], "professions": ["freelancer", "seniman", "perawat"], "referrals": ["terlihat tanda-tanda kurang tidur", "dirujuk oleh komunitas seni"]},
	{"base": "NPC-F", "names": ["Hasan", "Putra", "Gatot", "Yohanes"], "professions": ["petugas keamanan", "atasan divisi", "pejabat dinas"], "referrals": ["dirujuk setelah insiden di ruang rapat", "observasi internal fasilitas"]},
	{"base": "NPC-G", "names": ["Brian", "Jonathan", "Alvin", "Doni"], "professions": ["pemain piano", "pelatih musik", "musisi"], "referrals": ["bergumam nada yang sama terus-menerus", "dirujuk oleh komunitas seni"]},
	{"base": "NPC-H", "names": ["Cimeng", "Momo", "Gato", "Neko"], "professions": ["kucing", "penjaga rumah"], "referrals": ["sering membuat rumah berantakan", "dirujuk oleh majikannya"]},
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
	init_npc_sprite_mapping()


static func generate_new_patients(count: int, day: int, exclude_base_ids: Array = [], preferred_excludes: Array = [], existing_emotions: Array = []) -> Array[PatientData]:
	var patients: Array[PatientData] = []
	var used_emotions: Array = existing_emotions.duplicate()
	var used_bases: Array = exclude_base_ids.duplicate()

	for i in count:
		var emotion := _pick_emotion(used_emotions)
		used_emotions.append(emotion)
		var pool := _pick_available_pool(used_bases, preferred_excludes)
		if pool.has("base"):
			used_bases.append(pool.base)
		patients.append(_build_patient(emotion, day, i, pool))
	return patients


static func _pick_available_pool(used_bases: Array, preferred_excludes: Array = []) -> Dictionary:
	var available: Array[Dictionary] = []
	for p in BASE_NPC_POOLS:
		if not used_bases.has(p.base) and not preferred_excludes.has(p.base):
			available.append(p)

	# Jika tidak ada yang lolos karena preferred_excludes, gunakan yang penting tidak ada di used_bases
	if available.is_empty():
		for p in BASE_NPC_POOLS:
			if not used_bases.has(p.base):
				available.append(p)

	# Fallback aman jika semua base_npc_id sudah terpakai
	if available.is_empty():
		return BASE_NPC_POOLS[_rng.randi_range(0, BASE_NPC_POOLS.size() - 1)]

	return available[_rng.randi_range(0, available.size() - 1)]


static func _pick_emotion(used: Array) -> Emotion.Type:
	var available: Array = []
	for emotion in ALL_EMOTIONS:
		if not used.has(emotion):
			available.append(emotion)

	if available.is_empty():
		return ALL_EMOTIONS[_rng.randi_range(0, ALL_EMOTIONS.size() - 1)]

	return available[_rng.randi_range(0, available.size() - 1)]


static func _build_patient(emotion: Emotion.Type, day: int, index: int, pool: Dictionary = {}) -> PatientData:
	if pool.is_empty():
		pool = _pick_available_pool([])
	var patient := PatientData.new()
	patient.npc_instance_id = "%s-day%d-%d" % [emotion, day, index]
	patient.base_npc_id = pool.base
	patient.sprite_id = get_sprite_for_npc(pool.base)
	patient.display_name = pool.names[_rng.randi_range(0, pool.names.size() - 1)]
	patient.age = _rng.randi_range(18, 40)
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
