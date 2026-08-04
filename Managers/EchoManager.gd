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
var _game_over: bool = false


func start_game() -> void:
	day = 0
	_new_patients = []
	_control_patients = []
	_session_queue = []
	_pending_checkups = []
	_game_over = false
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

	# Sisa slot diisi pasien baru (komposisi Section 18)
	var remaining: int = GameConfig.SESSIONS_PER_DAY - _control_patients.size()
	_new_patients = PatientFactory.generate_new_patients(max(remaining, 0), day)

	_build_session_queue()
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
	if current_patient.topics_used.size() >= GameConfig.MAX_TOPICS_PER_SESSION:
		return Topic.Relevance.NEUTRAL

	current_patient.topics_used.append(topic)
	var relevance: Topic.Relevance = current_patient.get_relevance(topic)
	topic_reacted.emit(current_patient, topic, relevance)

	if current_patient.topics_used.size() >= GameConfig.MAX_TOPICS_PER_SESSION:
		investigation_finished.emit(current_patient)
	return relevance


func get_topics_remaining() -> int:
	if current_patient == null:
		return 0
	return GameConfig.MAX_TOPICS_PER_SESSION - current_patient.topics_used.size()


func has_topics_remaining() -> bool:
	return get_topics_remaining() > 0


# --- Decision (Section 12, 16, 36) ---

func commit_diagnosis(chosen_emotion: Emotion.Type, chosen_schedule: GameConfig.Schedule) -> void:
	if _game_over or current_patient == null:
		return

	var patient := current_patient
	var was_correct: bool = chosen_emotion == patient.true_emotion

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
	_start_next_session()


# --- End of Day (Section 16, 18, 36) ---

func _end_of_day() -> void:
	end_of_day_finished.emit(day)

	if _game_over:
		return

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
