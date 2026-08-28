class_name TestAchievements
extends RefCounted

const AchievementManagerClass = preload("res://achievements/achievement_manager.gd")

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_achievement_unlock_and_duplicate_guard())
	return results

func _test_achievement_unlock_and_duplicate_guard() -> Dictionary:
	var mgr = AchievementManagerClass.new()
	mgr._ready()
	
	var first_unlock: bool = mgr.unlock_achievement(&"first_night")
	var duplicate_unlock: bool = mgr.unlock_achievement(&"first_night") # Should return false
	var is_unlocked: bool = mgr.is_unlocked(&"first_night")
	
	var passed: bool = first_unlock and (not duplicate_unlock) and is_unlocked
	mgr.free()
	return {"name": "Achievements: Unlock Notification & Duplicate Guard", "passed": passed, "message": "Achievement unlocked and duplicate prevented"}
