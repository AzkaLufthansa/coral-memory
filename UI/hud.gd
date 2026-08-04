extends PanelContainer

@onready var day_label: Label = %DayLabel
@onready var session_label: Label = %SessionLabel
@onready var topics_label: Label = %TopicsLabel


func _ready() -> void:
	_update(EchoManager.day, 0, 0, GameConfig.MAX_TOPICS_PER_SESSION)


func set_day(day: int) -> void:
	_update(day, EchoManager.session_index, 0, GameConfig.MAX_TOPICS_PER_SESSION)


func set_session(session_index: int, total: int) -> void:
	_update(EchoManager.day, session_index, EchoManager.get_topics_remaining(), GameConfig.MAX_TOPICS_PER_SESSION)


func set_topics_remaining(remaining: int) -> void:
	_update(EchoManager.day, EchoManager.session_index, remaining, GameConfig.MAX_TOPICS_PER_SESSION)


func _update(day: int, session: int, remaining: int, max_topics: int) -> void:
	day_label.text = "Hari %d / %d" % [day, GameConfig.DAYS_TOTAL]
	session_label.text = "Sesi %d / %d" % [session, GameConfig.SESSIONS_PER_DAY]
	topics_label.text = "Pertanyaan tersisa: %d/%d" % [remaining, max_topics]
