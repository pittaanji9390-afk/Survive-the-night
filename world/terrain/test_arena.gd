class_name TestArena
extends Node2D

@onready var day_night_modulate: CanvasModulate = $DayNightModulate
@onready var spawn_point: Marker2D = $PlayerSpawnPoint

func _ready() -> void:
	ServiceLocator.register_service(&"World", self)
	_update_lighting()
	EventBus.time_tick.connect(_on_time_tick)
	EventBus.day_phase_changed.connect(_on_day_phase_changed)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"World")

func _process(_delta: float) -> void:
	_update_lighting()

func _update_lighting() -> void:
	if not day_night_modulate:
		return
	
	# Transition color between night tint (dark blue/purple) and day (warm white)
	var factor: float = TimeManager.daylight_factor
	var night_color: Color = Color(0.12, 0.14, 0.25, 1.0)
	var sunset_color: Color = Color(0.9, 0.55, 0.4, 1.0)
	var day_color: Color = Color(1.0, 0.98, 0.95, 1.0)
	
	var target_color: Color
	if factor < 0.2:
		target_color = night_color
	elif factor < 0.6:
		target_color = night_color.lerp(sunset_color, (factor - 0.2) / 0.4)
	else:
		target_color = sunset_color.lerp(day_color, (factor - 0.6) / 0.4)
	
	day_night_modulate.color = target_color

func _on_time_tick(_hour: int, _min: int) -> void:
	_update_lighting()

func _on_day_phase_changed(_phase: int) -> void:
	_update_lighting()
