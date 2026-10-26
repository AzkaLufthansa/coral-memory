extends Control

signal restart_requested

const MUSIC_GOOD_ENDING := preload("res://Assets/Audio/Music/Good_Ending.wav")
const MUSIC_BAD_ENDING := preload("res://Assets/Audio/Music/Bad_Ending.wav")

@onready var title_label: Label = %TitleLabel
@onready var detail_label: Label = %DetailLabel
@onready var restart_button: Button = %RestartButton

var _music_player: AudioStreamPlayer = null


func _ready() -> void:
	restart_button.pressed.connect(func() -> void: restart_requested.emit())


func _play_music(stream: AudioStream) -> void:
	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.bus = &"Music"
		add_child(_music_player)
	_music_player.stream = stream
	_music_player.play()


func _stop_music() -> void:
	if is_instance_valid(_music_player) and _music_player.playing:
		_music_player.stop()


func show_burst(patient: PatientData) -> void:
	title_label.text = "ECHO BURST"
	title_label.modulate = Color(0.9, 0.2, 0.2)
	detail_label.text = "%s (%s)\nEcho pasien pecah sebelum pemeriksaan kontrol tiba.\nGAME OVER — Hari %d" % [
		patient.display_name, patient.profession, EchoManager.day
	]
	visible = true
	_play_music(MUSIC_BAD_ENDING)


func show_ending(days: int) -> void:
	if days >= GameConfig.DAYS_TOTAL:
		title_label.text = "HARI KE-7 SELESAI"
	else:
		title_label.text = "SEMUA PASIEN TERDIAGNOSIS"
	title_label.modulate = Color(0.4, 0.8, 0.6)
	detail_label.text = "Semua pasien berhasil didiagnosis dengan benar.\nTidak ada Echo Burst selama %d hari." % days
	visible = true
	_play_music(MUSIC_GOOD_ENDING)


func show_game_over(detail: String = "") -> void:
	title_label.text = "GAME OVER"
	title_label.modulate = Color(0.9, 0.2, 0.2)
	if detail.is_empty():
		detail_label.text = "Anda gagal mendiagnosis semua pasien dengan benar."
	else:
		detail_label.text = detail
	visible = true
	_play_music(MUSIC_BAD_ENDING)


func _on_restart_button_pressed() -> void:
	_stop_music()
	if has_node("Click"):
		$Click.play()
