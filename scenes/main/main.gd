class_name MainGame
extends Node2D

@onready var world: TestArena = $World
@onready var player: PlayerController = $Player
@onready var camera: CameraController = $CameraController
@onready var hud: HUDController = $CanvasLayer/HUD
@onready var pause_menu: PauseMenu = $CanvasLayer/PauseMenu
@onready var debug_overlay: DebugOverlay = $DebugOverlay

func _ready() -> void:
	GameLogger.info("Main", "Initializing Survive the Night - Milestone 1 Foundation")
	
	if world and world.spawn_point and player:
		player.global_position = world.spawn_point.global_position
	
	if camera and player:
		camera.target_node = player
		camera.global_position = player.global_position
	
	GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	EventBus.notification_posted.emit("Welcome", "Survive the Night: WASD to Move, Shift to Sprint, E to Interact, F3 for Debug, Esc to Pause", "info")
