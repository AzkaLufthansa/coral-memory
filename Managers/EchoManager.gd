extends Node

signal day_started(day: int)
signal session_started(patient: PatientData, session_index: int, total_sessions: int)
signal topic_reacted(patient: PatientData, topic: Topic.Name, relevance: Topic.Relevance)
signal investigation_finished(patient: PatientData)
signal diagnosis_committed(patient: PatientData, was_correct: bool)
signal end_of_day_finished(day: int)
signal echo_burst(patient: PatientData)
signal game_ended(days_survived: int)
signal game_failed(detail: String)

var day: int = 0
var current_patient: PatientData = null
var session_index: int = 0

var _new_patients: Array = []
var _control_patients: Array = []
var _session_queue: Array = []
var _pending_checkups: Array = []
var _daily_patients: Dictionary = {}
var _all_admitted_patients: Array[PatientData] = []
var _game_over: bool = false
var _day_advancing: bool = false


func start_game() -> void:
	day = 0
	_new_patients = []
	_control_patients = []
	_session_queue = []
	_pending_checkups = []
	_daily_patients.clear()
	_all_admitted_patients.clear()
	_game_over = false
	_day_advancing = false
	PatientFactory.setup_rng()
	PatientFactory.init_npc_sprite_mapping()
	_start_next_day()


func _start_next_day() -> void:
	day += 1
	session_index = 0

	# Section 36 onNewDay: decay untuk pasien yang kontrolnya masih di masa depan.
	# currentDay = day yang baru dimulai; pasien dengan next_checkup_day == day
	# tidak di-decay (diperiksa hari ini).
	if not _process_new_day_decay():
		return

	# Pasien kontrol yang hari kontrolnya hari ini (Section 16/18)
	_control_patients = []
	for patient in _pending_checkups:
		if patient.next_checkup_day <= day:
			patient.is_control_patient = true
			_control_patients.append(patient)

	# Kumpulkan base_npc_id pasien yang sudah pernah terdaftar di klinik
	var admitted_base_ids: Array[String] = []
	for patient in _all_admitted_patients:
		if patient is PatientData:
			admitted_base_ids.append(patient.base_npc_id)

	# Sisa slot hanya diisi dari tipe base NPC yang belum pernah masuk klinik
	var unadmitted := get_unadmitted_base_npc_ids()
	var remaining: int = GameConfig.SESSIONS_PER_DAY - _control_patients.size()
	var count_to_generate: int = mini(max(remaining, 0), unadmitted.size())

	# Kumpulkan emosi dari pasien yang sudah pernah terdaftar agar variasi emosi merata
	var admitted_emotions: Array = []
	for patient in _all_admitted_patients:
		if patient is PatientData:
			admitted_emotions.append(patient.true_emotion)

	_new_patients = []
	if count_to_generate > 0:
		_new_patients = PatientFactory.generate_new_patients(count_to_generate, day, admitted_base_ids, [], admitted_emotions)
		for p in _new_patients:
			if p is PatientData and not _all_admitted_patients.has(p):
				_all_admitted_patients.append(p)

	_build_session_queue()

	# Catat seluruh pasien yang dijadwalkan pada hari ini
	var day_patients: Array[PatientData] = []
	for p in _control_patients:
		if p is PatientData:
			day_patients.append(p)
	for p in _new_patients:
		if p is PatientData:
			day_patients.append(p)
	_daily_patients[day] = day_patients

	day_started.emit(day)
	_start_next_session()


func _build_session_queue() -> void:
	_session_queue = []
	_session_queue.append_array(_control_patients)
	_session_queue.append_array(_new_patients)


func _start_next_session() -> void:
	if _game_over:
		return
	if _session_queue.is_empty():
		current_patient = null
		_end_of_day()
		return

	current_patient = _session_queue.pop_front()
	current_patient.reset_session_state()
	session_index += 1
	session_started.emit(current_patient, session_index, GameConfig.SESSIONS_PER_DAY)


# --- Investigasi (Section 14) ---

func ask_topic(topic: Topic.Name) -> Topic.Relevance:
	if _game_over or current_patient == null:
		return Topic.Relevance.NEUTRAL
	var max_topics := 1 if current_patient.is_diagnosed else GameConfig.MAX_TOPICS_PER_SESSION
	if current_patient.topics_used.size() >= max_topics:
		return Topic.Relevance.NEUTRAL

	current_patient.topics_used.append(topic)
	var relevance: Topic.Relevance = current_patient.get_relevance(topic)
	topic_reacted.emit(current_patient, topic, relevance)

	if current_patient.topics_used.size() >= max_topics:
		investigation_finished.emit(current_patient)
	return relevance


func get_topics_remaining() -> int:
	if current_patient == null:
		return 0
	var max_topics := 1 if current_patient.is_diagnosed else GameConfig.MAX_TOPICS_PER_SESSION
	return maxi(0, max_topics - current_patient.topics_used.size())


func has_topics_remaining() -> bool:
	return get_topics_remaining() > 0


# --- Decision (Section 12, 16, 36) ---

func commit_diagnosis(chosen_emotion: Emotion.Type, chosen_schedule: GameConfig.Schedule) -> void:
	if _game_over or current_patient == null:
		return

	var patient := current_patient
	var was_already_diagnosed: bool = patient.is_diagnosed
	var was_correct: bool = chosen_emotion == patient.true_emotion

	# Mark as diagnosed if correct core echo is chosen AND echo was transformed to phase 2
	# regardless of which schedule day option chosen
	if was_correct and (patient.echo_transformed or patient.is_diagnosed):
		patient.is_diagnosed = true
	elif not was_correct:
		patient.is_diagnosed = false
		patient.echo_transformed = false

	# Section 36 onDecisionSubmit
	if was_correct:
		patient.stability = clampi(patient.stability + GameConfig.RECOVERY_BONUS, GameConfig.MIN_STABILITY, GameConfig.MAX_STABILITY)
	else:
		patient.stability = clampi(patient.stability - patient.misdiagnosis_penalty, GameConfig.MIN_STABILITY, GameConfig.MAX_STABILITY)

	var schedule_days: int = GameConfig.schedule_days(chosen_schedule)
	var tolerance: int = patient.schedule_tolerance_map.get(chosen_schedule, 0)
	patient.next_checkup_day = day + schedule_days
	patient.pending_decay_per_day = maxi(patient.decay_rate - tolerance, GameConfig.MIN_DECAY_PER_DAY)
	patient.is_control_patient = true

	patient.diagnosis_history.append({
		"day": day,
		"chosen_emotion": chosen_emotion,
		"chosen_schedule": chosen_schedule,
		"was_correct": was_correct,
	})

	# Pengelolaan status kontrol dan pending checkups:
	# Jika pasien SEBELUM sesi ini sudah didiagnosis (is_diagnosed == true) dan hari ini
	# menjalani sesi kontrol ("Apa kabarmu?") dengan diagnosis tetap benar:
	# Pasien dinyatakan tuntas/sembuh dan dikeluarkan dari daftar kontrol pending!
	if was_already_diagnosed and patient.is_diagnosed:
		_pending_checkups.erase(patient)
		patient.next_checkup_day = -1
	else:
		# Jika baru pertama kali didiagnosis (atau salah diagnosis sehingga perlu kontrol ulang):
		# Masukkan/pertahankan di antrean kontrol pending
		if not _pending_checkups.has(patient):
			_pending_checkups.append(patient)

	diagnosis_committed.emit(patient, was_correct)


func call_next_patient() -> void:
	if _game_over or _day_advancing:
		return
	_handle_patient_leaving(current_patient)
	if _game_over:
		return
	_start_next_session()


func _was_patient_diagnosed_today(patient: PatientData) -> bool:
	if patient == null:
		return false
	for h in patient.diagnosis_history:
		if h.get("day", -1) == day and not h.get("unattended", false):
			return true
	return false


func _handle_patient_leaving(patient: PatientData) -> void:
	if patient == null or _was_patient_diagnosed_today(patient):
		return

	# Kasus 1: Pasien kontrol yang sudah terdiagnosis dan telah ditanya "Apa kabarmu?"
	if patient.is_diagnosed and not patient.topics_used.is_empty():
		_pending_checkups.erase(patient)
		patient.next_checkup_day = -1
		patient.is_control_patient = false
		patient.stability = clampi(patient.stability + GameConfig.RECOVERY_BONUS, GameConfig.MIN_STABILITY, GameConfig.MAX_STABILITY)
		patient.diagnosis_history.append({
			"day": day,
			"control_checkup": true,
			"was_correct": true,
		})
		return

	# Kasus 2: Pasien tidak dilayani / dilewati tanpa diagnosa (unattended)
	_handle_unattended_patient(patient)


func _handle_unattended_patient(patient: PatientData) -> void:
	if patient == null or _was_patient_diagnosed_today(patient):
		return

	# Pasien dilewati tanpa diagnosa / tidak dilayani (unattended):
	# Pasien TIDAK boleh dianggap terdiagnosis!
	patient.is_diagnosed = false
	patient.echo_transformed = false

	# Penalti stabilitas karena diabaikan
	patient.stability = clampi(patient.stability - patient.decay_rate, GameConfig.MIN_STABILITY, GameConfig.MAX_STABILITY)

	# Jadwalkan ulang agar dokter tetap harus memeriksanya di hari berikutnya
	patient.next_checkup_day = day + 1
	patient.pending_decay_per_day = patient.decay_rate
	patient.is_control_patient = true

	patient.diagnosis_history.append({
		"day": day,
		"unattended": true,
		"was_correct": false,
	})

	if not _pending_checkups.has(patient):
		_pending_checkups.append(patient)

	if patient.stability <= GameConfig.MIN_STABILITY:
		_game_over = true
		echo_burst.emit(patient)


# --- End of Day (Section 16, 18, 36) ---

func _end_of_day() -> void:
	# Guard agar bel/next yang diklik berulang tidak memicu end-of-day
	# berkali-kali (yang bisa melewati hari).
	if _game_over or _day_advancing:
		return
	_day_advancing = true
	end_of_day_finished.emit(day)


func advance_day() -> void:
	if _game_over:
		return

	_day_advancing = false

	if check_game_conclusion():
		return

	_start_next_day()


func get_all_admitted_patients() -> Array[PatientData]:
	return _all_admitted_patients


func get_unadmitted_base_npc_ids() -> Array[String]:
	var admitted_bases: Array[String] = []
	for p in _all_admitted_patients:
		if p is PatientData:
			admitted_bases.append(p.base_npc_id)
	var unadmitted: Array[String] = []
	for pool in PatientFactory.BASE_NPC_POOLS:
		if not admitted_bases.has(pool.base):
			unadmitted.append(pool.base)
	return unadmitted


func are_all_patients_diagnosed() -> bool:
	if _all_admitted_patients.size() < PatientFactory.BASE_NPC_POOLS.size():
		return false
	for patient in _all_admitted_patients:
		if patient is PatientData and not patient.is_diagnosed:
			return false
	return true


func has_remaining_patients_to_check() -> bool:
	if not _session_queue.is_empty():
		return true

	if day >= GameConfig.DAYS_TOTAL:
		return false

	if not get_unadmitted_base_npc_ids().is_empty():
		return true

	if not _pending_checkups.is_empty():
		return true

	# Pastikan jika ada pasien yang sudah masuk klinik tapi belum terdiagnosis,
	# permainan tetap berjalan selama masih ada hari tersisa (< DAYS_TOTAL)
	for p in _all_admitted_patients:
		if p is PatientData and not p.is_diagnosed:
			return true

	return false


func check_game_conclusion() -> bool:
	if _game_over:
		return true

	if has_remaining_patients_to_check():
		return false

	_game_over = true

	if are_all_patients_diagnosed():
		game_ended.emit(day)
		return true
	else:
		var undiagnosed_names: Array[String] = []
		for p in _all_admitted_patients:
			if p is PatientData and not p.is_diagnosed:
				undiagnosed_names.append(p.display_name)
		var detail := ""
		if not undiagnosed_names.is_empty():
			detail = "Pasien yang belum terdiagnosis: %s\nGAME OVER" % ", ".join(undiagnosed_names)
		else:
			detail = "Tidak semua pasien berhasil didiagnosis dengan benar.\nGAME OVER"
		game_failed.emit(detail)
		return true


func _process_new_day_decay() -> bool:
	for patient in _pending_checkups.duplicate():
		if patient.next_checkup_day > day:
			patient.stability -= patient.pending_decay_per_day
			if patient.stability <= GameConfig.MIN_STABILITY:
				_game_over = true
				echo_burst.emit(patient)
				return false
	return true


func is_game_over() -> bool:
	return _game_over


func get_pending_checkups() -> Array:
	return _pending_checkups


func get_daily_patients(target_day: int) -> Array[PatientData]:
	if _daily_patients.has(target_day):
		var list: Array[PatientData] = []
		for p in _daily_patients[target_day]:
			if p is PatientData:
				list.append(p)
		return list
	return []
