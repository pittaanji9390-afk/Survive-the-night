class_name StatusEffect
extends Resource

enum EffectType {
	BLEEDING,
	POISONED,
	FREEZING,
	OVERHEATING,
	WELL_FED,
	HYDRATED,
	RESTED
}

@export var effect_id: StringName = &"effect_default"
@export var display_name: String = "Status Effect"
@export var effect_type: EffectType = EffectType.WELL_FED
@export var is_buff: bool = false
@export var duration_sec: float = 10.0:
	set(val):
		duration_sec = val
		remaining_time = val

@export var tick_interval_sec: float = 1.0

@export var damage_per_tick: float = 0.0
@export var heal_per_tick: float = 0.0
@export var speed_multiplier: float = 1.0
@export var stamina_regen_multiplier: float = 1.0

var remaining_time: float = 10.0
var _tick_timer: float = 0.0

func _init() -> void:
	remaining_time = duration_sec

func duplicate_effect() -> StatusEffect:
	var copy: StatusEffect = StatusEffect.new()
	copy.effect_id = effect_id
	copy.display_name = display_name
	copy.effect_type = effect_type
	copy.is_buff = is_buff
	copy.duration_sec = duration_sec
	copy.remaining_time = duration_sec
	copy.tick_interval_sec = tick_interval_sec
	copy.damage_per_tick = damage_per_tick
	copy.heal_per_tick = heal_per_tick
	copy.speed_multiplier = speed_multiplier
	copy.stamina_regen_multiplier = stamina_regen_multiplier
	return copy

func update_effect(delta: float, target_stats: PlayerStats) -> bool:
	remaining_time -= delta
	_tick_timer += delta
	
	if tick_interval_sec > 0.0:
		while _tick_timer >= tick_interval_sec:
			_tick_timer -= tick_interval_sec
			_apply_tick(target_stats)
	
	return remaining_time <= 0.0

func _apply_tick(stats: PlayerStats) -> void:
	if not stats:
		return
	if damage_per_tick > 0.0:
		stats.apply_damage(damage_per_tick, null, false)
	if heal_per_tick > 0.0:
		stats.heal(heal_per_tick)
