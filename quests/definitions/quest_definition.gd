class_name QuestDefinition
extends Resource

enum QuestType {
	GATHER,
	CRAFT,
	SURVIVE_NIGHTS,
	KILL_ENEMIES,
	EXPLORE
}

@export var quest_id: StringName = &"quest_default"
@export var title: String = "Quest Title"
@export_multiline var description: String = "Quest objective description."
@export var quest_type: QuestType = QuestType.GATHER
@export var target_id: StringName = &"wood"
@export var target_count: int = 10
@export var current_count: int = 0
@export var is_completed: bool = false
@export var reward_xp: int = 50
@export var reward_items: Array[Dictionary] = []

func add_progress(amount: int) -> bool:
	if is_completed:
		return false
	current_count = mini(target_count, current_count + amount)
	if current_count >= target_count:
		is_completed = true
		return true
	return false
