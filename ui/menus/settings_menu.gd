class_name SettingsMenu
extends Control

@onready var master_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/MasterHBox/MasterSlider
@onready var sfx_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/SFXHBox/SFXSlider
@onready var music_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/MusicHBox/MusicSlider
@onready var fullscreen_check: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/FullscreenCheck
@onready var back_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/BackBtn

var _sound_mgr: SoundManager = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if master_slider:
		master_slider.value_changed.connect(_on_master_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_changed)
	if fullscreen_check:
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	if back_btn:
		back_btn.pressed.connect(func(): visible = false)

func open_settings() -> void:
	_sound_mgr = ServiceLocator.get_service(&"SoundManager") as SoundManager
	visible = true

func _on_master_changed(val: float) -> void:
	if _sound_mgr:
		_sound_mgr.master_volume = val / 100.0

func _on_sfx_changed(val: float) -> void:
	if _sound_mgr:
		_sound_mgr.sfx_volume = val / 100.0

func _on_music_changed(val: float) -> void:
	if _sound_mgr:
		_sound_mgr.music_volume = val / 100.0

func _on_fullscreen_toggled(toggled: bool) -> void:
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
