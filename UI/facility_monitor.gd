extends PanelContainer

signal monitor_closed

@onready var day_label: Label = %DayLabel
@onready var session_label: Label = %SessionLabel
@onready var patients_label: Label = %PatientsLabel
@onready var time_label: Label = %TimeLabel


func _ready() -> void:
	%CloseButton.pressed.connect(func() -> void: monitor_closed.emit())


func show_monitor() -> void:
	day_label.text = "HARI %d / %d" % [EchoManager.day, GameConfig.DAYS_TOTAL]
	session_label.text = "SESI %d / %d" % [EchoManager.session_index, GameConfig.SESSIONS_PER_DAY]
	var total := EchoManager.get_pending_checkups().size()
	patients_label.text = "Pasien terdaftar dalam pemantauan: %d" % total
	var hour := 8 + (EchoManager.day - 1) * 2
	time_label.text = "Waktu: %02d:%02d" % [hour % 24, 0]
	visible = true


func _on_close() -> void:
	visible = false
	monitor_closed.emit()
