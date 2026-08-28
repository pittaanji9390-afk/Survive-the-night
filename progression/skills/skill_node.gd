class_name SkillNode
extends Resource

enum BranchType {
	SURVIVAL,
	HARVESTING,
	WARRIOR,
	BUILDER
}

@export var skill_id: StringName = &"skill_default"
@export var title: String = "Skill Title"
@export_multiline var description: String = "Skill description."
@export var branch: BranchType = BranchType.SURVIVAL
@export var point_cost: int = 1
@export var prerequisites: Array[StringName] = []

# Stat bonuses: {"health": 20.0, "damage": 5.0, "speed": 15.0, "armor": 2.0}
@export var stat_bonuses: Dictionary = {}
