class_name DebugOverlay
extends CanvasLayer

@onready var label: Label = $MarginContainer/Label

var is_overlay_visible: bool = false
var _player: PlayerController = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		is_overlay_visible = !is_overlay_visible
		visible = is_overlay_visible
		EventBus.debug_mode_toggled.emit(is_overlay_visible)

func _process(_delta: float) -> void:
	if not visible or not label:
		return
	
	if not is_instance_valid(_player):
		_player = ServiceLocator.get_service(&"Player") as PlayerController
	
	var fps: int = int(Engine.get_frames_per_second())
	var state_str: String = GameStateManager._state_to_string(GameStateManager.current_state)
	var time_str: String = "%s (Day %d, %s, Light: %.2f)" % [
		TimeManager.get_time_string(),
		TimeManager.current_day,
		TimeManager.get_phase_name(),
		TimeManager.daylight_factor
	]
	
	var player_str: String = "No Player"
	if is_instance_valid(_player):
		var pos: Vector2 = _player.global_position
		var vel: Vector2 = _player.velocity
		var p_state: String = _player.state_machine.get_state_name()
		var p_health: float = _player.stats.health.get_current_value()
		var p_stam: float = _player.stats.stamina.get_current_value()
		var p_hung: float = _player.stats.hunger.get_current_value()
		var p_temp: float = _player.stats.temperature.get_current_value()
		player_str = "Pos: (%.1f, %.1f) | Vel: (%.1f, %.1f) | State: %s\nHP: %.1f/%.1f | Stam: %.1f/%.1f | Hunger: %.1f/%.1f | Temp: %.1f°C" % [
			pos.x, pos.y, vel.x, vel.y, p_state,
			p_health, _player.stats.health.get_max_value(),
			p_stam, _player.stats.stamina.get_max_value(),
			p_hung, _player.stats.hunger.get_max_value(),
			p_temp
		]
	
	var mem_mb: float = float(OS.get_static_memory_usage()) / (1024.0 * 1024.0)
	
	label.text = "[F3] DEBUG OVERLAY\nFPS: %d | Mem: %.1f MB\nGameState: %s\nTime: %s\n%s" % [
		fps, mem_mb, state_str, time_str, player_str
	]
