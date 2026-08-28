class_name AchievementManager
extends Node

signal achievement_unlocked(id: StringName, title: String, desc: String)

var unlocked_achievements: Dictionary = {}

var achievement_defs: Dictionary = {
	&"first_night": { "title": "Dawn of Hope", "desc": "Survive your very first night in the wilderness." },
	&"craft_first_tool": { "title": "Stone Age Artisan", "desc": "Craft your first stone tool." },
	&"slay_boss_terror": { "title": "Nightmare Cleansed", "desc": "Defeat The Night Terror boss." },
	&"slay_boss_brood": { "title": "Arachnophobia", "desc": "Vanquish Broodmother Arachna in the deep dungeon." },
	&"slay_boss_titan": { "title": "Titan Extinguisher", "desc": "Extinguish Ignis the Pyroclastic Titan." },
	&"build_power_grid": { "title": "Industrial Revolution", "desc": "Produce 100W of electrical power." },
	&"tame_first_pet": { "title": "Wild Friend", "desc": "Tame your first wild companion." },
	&"arcade_champion": { "title": "Token Collector", "desc": "Earn 50 tokens in the Arcade Hub." }
}

func _ready() -> void:
	ServiceLocator.register_service(&"AchievementManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"AchievementManager")

func unlock_achievement(id: StringName) -> bool:
	if not achievement_defs.has(id) or unlocked_achievements.has(id):
		return false
	
	unlocked_achievements[id] = true
	var data: Dictionary = achievement_defs[id]
	achievement_unlocked.emit(id, data.title, data.desc)
	EventBus.notification_posted.emit("🏆 ACHIEVEMENT UNLOCKED!", "%s: %s" % [data.title, data.desc], "trophy")
	GameLogger.info("AchievementManager", "Unlocked: %s" % data.title)
	return true

func is_unlocked(id: StringName) -> bool:
	return unlocked_achievements.has(id)
