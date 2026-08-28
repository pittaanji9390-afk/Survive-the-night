class_name ExperienceManager
extends Node

signal level_up(new_level: int, skill_points: int)
signal xp_gained(amount: int, current_xp: int, next_level_xp: int)

var current_level: int = 1
var current_xp: int = 0
var available_skill_points: int = 3

func _ready() -> void:
	ServiceLocator.register_service(&"ExperienceManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"ExperienceManager")

func get_xp_for_next_level(level: int) -> int:
	return int(floor(100.0 * pow(1.35, float(level - 1))))

func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	
	current_xp += amount
	var needed: int = get_xp_for_next_level(current_level)
	
	while current_xp >= needed:
		current_xp -= needed
		current_level += 1
		available_skill_points += 1
		level_up.emit(current_level, available_skill_points)
		EventBus.player_leveled_up.emit(current_level, available_skill_points)
		EventBus.notification_posted.emit("LEVEL UP!", "Reached Level %d! (+1 Skill Point)" % current_level, "level")
		EventBus.screen_shake_requested.emit(0.2)
		needed = get_xp_for_next_level(current_level)
	
	xp_gained.emit(amount, current_xp, needed)

func serialize() -> Dictionary:
	return {
		"level": current_level,
		"xp": current_xp,
		"skill_points": available_skill_points
	}

func deserialize(data: Dictionary) -> void:
	current_level = int(data.get("level", 1))
	current_xp = int(data.get("xp", 0))
	available_skill_points = int(data.get("skill_points", 0))
	var needed: int = get_xp_for_next_level(current_level)
	xp_gained.emit(0, current_xp, needed)
