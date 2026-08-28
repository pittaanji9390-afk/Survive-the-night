class_name HitboxComponent
extends Area2D

signal hit_landed(target: Node2D, damage_dealt: float)

@export var damage: float = 10.0
@export var knockback_force: float = 150.0
@export var is_critical: bool = false
@export var crit_multiplier: float = 1.5
@export var hit_team: int = 0 # 0=Player, 1=Enemy, 2=Neutral

var source_entity: Node2D = null

func _ready() -> void:
	collision_layer = 16 # Physics Layer 5 (Hitboxes)
	collision_mask = 32  # Physics Layer 6 (Hurtboxes)

func get_effective_damage() -> float:
	var final_dmg: float = damage
	if is_critical or (randf() < 0.15): # 15% base crit chance
		final_dmg *= crit_multiplier
		is_critical = true
	return final_dmg
