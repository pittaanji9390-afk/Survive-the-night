class_name PauseMenu
extends Control

@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	EventBus.game_paused.connect(_on_game_paused)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		toggle_pause()

func toggle_pause() -> void:
	if GameStateManager.is_state(GameStateManagerService.GameState.PAUSED):
		GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	elif GameStateManager.is_state(GameStateManagerService.GameState.PLAYING):
		GameStateManager.change_state(GameStateManagerService.GameState.PAUSED)

func _on_game_paused(is_paused: bool) -> void:
	visible = is_paused

func _on_resume_pressed() -> void:
	GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)

func _on_restart_pressed() -> void:
	GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
