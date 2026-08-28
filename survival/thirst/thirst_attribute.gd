class_name ThirstAttribute
extends RefCounted

signal thirst_depleted()

var current_thirst: float = 100.0
var max_thirst: float = 100.0
var drain_rate_per_sec: float = 0.15

func update_thirst(delta: float, is_sprinting: bool, ambient_temp: float, player_stats: PlayerStats) -> void:
	var multiplier: float = 1.0
	if is_sprinting:
		multiplier *= 2.2
	if ambient_temp > 22.0:
		multiplier *= 1.4
	
	current_thirst = maxf(0.0, current_thirst - (drain_rate_per_sec * multiplier * delta))
	
	if current_thirst <= 0.0:
		thirst_depleted.emit()
		if player_stats:
			# Dehydration damage
			player_stats.apply_damage(1.5 * delta, null, false)

func drink(amount: float) -> void:
	current_thirst = minf(max_thirst, current_thirst + amount)

func get_ratio() -> float:
	return current_thirst / max_thirst if max_thirst > 0.0 else 0.0
