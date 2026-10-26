extends Node

signal day_started(day: int)
signal session_started(patient: PatientData, session_index: int, total_sessions: int)
signal topic_reacted(patient: PatientData, topic: Topic.Name, relevance: Topic.Relevance)
signal investigation_finished(patient: PatientData)
signal diagnosis_committed(patient: PatientData, was_correct: bool)
signal end_of_day_finished(day: int)
signal echo_burst(patient: PatientData)
signal game_ended(days_survived: int)

var day: int = 0
var current_patient: PatientData = null
var session_index: int = 0

var _new_patients: Array = []
var _control_patients: Array = []
var _session_queue: Array = []
var _pending_checkups: Array = []
var _daily_patients: Dictionary = {}
var _game_over: bool = false
var _day_advancing: bool = false


func start_game() -> void:
	day = 0
	_new_patients = []
	_control_patients = []
	_session_queue = []
	_pending_checkups = []
	_daily_patients.clear()
	_game_over = false
	_day_advancing = false
	PatientFactory.setup_rng()
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
		if patient.next_checkup_day == day:
			patient.is_control_patient = true
			_control_patients.append(patient)

	# Kumpulkan base_npc_id pasien kontrol hari ini agar tidak duplikat dengan pasien baru
	var used_base_ids: Array[String] = []
	for patient in _control_patients:
		if patient is PatientData:
			used_base_ids.append(patient.base_npc_id)

	# Kumpulkan base_npc_id pasien yang masih menunggu jadwal kontrol di hari mendatang
	var future_pending_base_ids: Array[String] = []
	for patient in _pending_checkups:
		if patient is PatientData and patient.next_checkup_day > day:
			future_pending_base_ids.append(patient.base_npc_id)

	# Sisa slot diisi pasien baru (komposisi Section 18) tanpa duplikasi tipe NPC
	var remaining: int = GameConfig.SESSIONS_PER_DAY - _control_patients.size()
	_new_patients = PatientFactory.generate_new_patients(max(remaining, 0), day, used_base_ids, future_pending_base_ids)

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

	if not _pending_checkups.has(patient):
		_pending_checkups.append(patient)

	diagnosis_committed.emit(patient, was_correct)


func call_next_patient() -> void:
	if _game_over or _day_advancing:
		return
	_start_next_session()


# --- End of Day (Section 16, 18, 36) ---

func _end_of_day() -> void:
	# Guard agar bel/next yang diklik berulang tidak memicu end-of-day
	# berkali-kali (yang bisa melewati hari).
	if _day_advancing:
		return
	_day_advancing = true
	end_of_day_finished.emit(day)


func advance_day() -> void:
	if _game_over:
		return

	_day_advancing = false

	if day >= GameConfig.DAYS_TOTAL:
		game_ended.emit(day)
		return

	_start_next_day()


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
