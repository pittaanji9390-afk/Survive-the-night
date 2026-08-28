class_name DamagePipeline
extends RefCounted

static func calculate_final_damage(base_dmg: float, scaling_stat: float, crit_mult: float, is_crit: bool, target_armor: float) -> float:
	var scaled: float = base_dmg * (1.0 + (scaling_stat * 0.05))
	var with_crit: float = scaled * (crit_mult if is_crit else 1.0)
	var mitigated: float = maxf(1.0, with_crit - target_armor)
	return mitigated

static func spawn_damage_number(parent: Node, pos: Vector2, amount: float, is_crit: bool) -> void:
	if not parent:
		return
	var scene: PackedScene = preload("res://scenes/effects/floating_damage_number.tscn")
	var num: FloatingDamageNumber = scene.instantiate() as FloatingDamageNumber
	num.global_position = pos + Vector2(randf_range(-12, 12), -10)
	num.damage_amount = amount
	num.is_critical = is_crit
	parent.add_child(num)
