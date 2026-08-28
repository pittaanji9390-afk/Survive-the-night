class_name SoundManager
extends Node

@export var master_volume: float = 1.0
@export var sfx_volume: float = 1.0
@export var music_volume: float = 0.8

var _audio_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	ServiceLocator.register_service(&"SoundManager", self)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"SoundManager")

func _setup_audio_players() -> void:
	for i in range(8):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(p)
		_audio_players.append(p)

func play_sfx_sample(pitch_scale: float = 1.0) -> void:
	if sfx_volume <= 0.0 or master_volume <= 0.0:
		return
	
	for p in _audio_players:
		if not p.playing:
			p.pitch_scale = pitch_scale
			p.volume_db = linear_to_db(sfx_volume * master_volume)
			# Play sample
			return
