class_name TechNode
extends Resource

enum Era {
	PRIMITIVE,
	BRONZE,
	IRON,
	ADVANCED
}

@export var tech_id: StringName = &"tech_default"
@export var title: String = "Technology"
@export_multiline var description: String = "Technology description."
@export var era: Era = Era.PRIMITIVE
@export var tier: int = 1
@export var cost_research_points: int = 10

# Prerequisite tech IDs that must be researched first
@export var prerequisites: Array[StringName] = []

# Optional raw material costs: [{ "id": StringName, "count": int }]
@export var material_costs: Array[Dictionary] = []

# List of crafting recipe IDs unlocked by researching this node
@export var unlocked_recipes: Array[StringName] = []

# Flat stat bonuses granted upon unlocking (e.g. {"max_health": 10.0, "attack_power": 2.0})
@export var stat_bonuses: Dictionary = {}
