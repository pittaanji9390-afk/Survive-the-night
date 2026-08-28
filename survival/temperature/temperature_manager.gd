class_name TemperatureManager
extends Node

signal temperature_updated(body_temp: float, ambient_temp: float)

@export var base_body_temperature: float = 37.0
@export var freezing_threshold: float = 30.0
@export var hypothermia_damage_rate: float = 2.5

var current_body_temperature: float = 37.0
var ambient_temperature: float = 20.0

var _player: Node2D = null
var _player_stats: PlayerStats = null
var _status_mgr: StatusEffectManager = null

var _freezing_effect_template: StatusEffect = null

func _ready() -> void:
	ServiceLocator.register_service(&"TemperatureManager", self)
	_setup_effects()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"TemperatureManager")

func _setup_effects() -> void:
	_freezing_effect_template = StatusEffect.new()
	_freezing_effect_template.effect_id = &"effect_freezing"
	_freezing_effect_template.display_name = "Hypothermia (Freezing)"
	_freezing_effect_template.effect_type = StatusEffect.EffectType.FREEZING
	_freezing_effect_template.is_buff = false
	_freezing_effect_template.duration_sec = 4.0
	_freezing_effect_template.tick_interval_sec = 1.0
	_freezing_effect_template.damage_per_tick = hypothermia_damage_rate
	_freezing_effect_template.speed_multiplier = 0.7

func _process(delta: float) -> void:
	_bind_player()
	_calculate_ambient_temperature()
	_update_body_temperature(delta)

func _bind_player() -> void:
	if not _player:
		_player = ServiceLocator.get_service(&"Player") as Node2D
		if _player:
			_player_stats = _player.get_node_or_null("PlayerStats") as PlayerStats
			_status_mgr = _player.get_node_or_null("StatusEffectManager") as StatusEffectManager

func _calculate_ambient_temperature() -> void:
	var hour: float = TimeManager.current_hour
	
	# Sinusoidal diurnal temperature cycle: peak 24°C at 14:00, trough -6°C at 02:00
	var phase: float = (hour - 8.0) / 24.0 * TAU
	var base_temp: float = 9.0 + sin(phase) * 15.0 # Ranges from -6°C to +24°C
	
	var heat_source_bonus: float = _calculate_nearby_heat_sources()
	ambient_temperature = base_temp + heat_source_bonus

func _calculate_nearby_heat_sources() -> float:
	if not _player:
		return 0.0
	
	var total_heat: float = 0.0
	var stations: Array[Node] = get_tree().get_nodes_in_group("crafting_station")
	for s in stations:
		if s is Node2D:
			var d: float = _player.global_position.distance_to((s as Node2D).global_position)
			if d <= 140.0:
				var falloff: float = 1.0 - (d / 140.0)
				total_heat += 28.0 * falloff
	
	var structures: Array[Node] = get_tree().get_nodes_in_group("structure")
	for st in structures:
		if st is Node2D and (st.get("structure_id") == &"standing_torch" or st.get("structure_id") == &"bonfire"):
			var dist: float = _player.global_position.distance_to((st as Node2D).global_position)
			if dist <= 120.0:
				var falloff: float = 1.0 - (dist / 120.0)
				total_heat += 22.0 * falloff
	
	return minf(total_heat, 35.0)

func _update_body_temperature(delta: float) -> void:
	var target_temp: float = 37.0
	if ambient_temperature < 0.0:
		# Ambient is sub-zero: body temp slowly pulls downward
		target_temp = 25.0 + (ambient_temperature * 0.8)
	elif ambient_temperature > 20.0:
		# Pleasant warmth: normal 37°C
		target_temp = 37.0
	
	var rate: float = 0.4 * delta
	current_body_temperature = move_toward(current_body_temperature, target_temp, rate)
	
	temperature_updated.emit(current_body_temperature, ambient_temperature)
	
	# Apply hypothermia freezing status if critically cold
	if current_body_temperature <= freezing_threshold:
		if _status_mgr:
			_status_mgr.apply_effect(_freezing_effect_template)
	else:
		if _status_mgr and _status_mgr.has_effect(&"effect_freezing"):
			_status_mgr.remove_effect(&"effect_freezing")
