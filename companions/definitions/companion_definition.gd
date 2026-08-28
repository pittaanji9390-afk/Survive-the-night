class_name CompanionDefinition
extends Resource

enum CompanionStance {
	FOLLOW,
	STAY_GUARD,
	AGGRESSIVE
}

@export var companion_id: StringName = &"companion_wolf"
@export var species_name: String = "Dire Wolf"
@export var favorite_food_id: StringName = &"cooked_meat"
@export var tame_food_cost: int = 3
@export var base_health: float = 120.0
@export var base_damage: float = 18.0
@export var is_rideable: bool = true
@export var mount_speed_bonus: float = 50.0
