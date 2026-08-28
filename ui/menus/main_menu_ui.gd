class_name MainMenuUI
extends Control

@onready var new_game_btn: Button = $VBoxContainer/NewGameButton
@onready var continue_btn: Button = $VBoxContainer/ContinueButton
@onready var arcade_btn: Button = $VBoxContainer/ArcadeButton
@onready var settings_btn: Button = $VBoxContainer/SettingsButton
@onready var quit_btn: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	if new_game_btn: new_game_btn.pressed.connect(_on_new_game_pressed)
	if continue_btn: continue_btn.pressed.connect(_on_continue_pressed)
	if arcade_btn: arcade_btn.pressed.connect(_on_arcade_pressed)
	if settings_btn: settings_btn.pressed.connect(_on_settings_pressed)
	if quit_btn: quit_btn.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_continue_pressed() -> void:
	var save_mgr: SaveManager = ServiceLocator.get_service(&"SaveManager") as SaveManager
	if save_mgr:
		save_mgr.load_game(1)
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_arcade_pressed() -> void:
	EventBus.notification_posted.emit("Arcade Hub", "Entering Arcade Zone...", "arcade")

func _on_settings_pressed() -> void:
	EventBus.notification_posted.emit("Settings", "Audio / Video Configuration", "gear")

func _on_quit_pressed() -> void:
	get_tree().quit()
