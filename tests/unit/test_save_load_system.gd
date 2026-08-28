class_name TestSaveLoadSystem
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_save_data_structure())
	results.append(_test_persistence_roundtrip())
	return results

func _test_save_data_structure() -> Dictionary:
	var save_mgr: SaveManager = SaveManager.new()
	save_mgr._ready()
	
	var data: Dictionary = save_mgr._gather_save_data()
	var has_time: bool = data.has("day_number") and data.has("day_time")
	var has_timestamp: bool = data.has("timestamp")
	
	var passed: bool = has_time and has_timestamp
	save_mgr.free()
	return {"name": "Persistence: Save Data Packaging", "passed": passed, "message": "Save metadata validated"}

func _test_persistence_roundtrip() -> Dictionary:
	var exp_a: ExperienceManager = ExperienceManager.new()
	exp_a.current_level = 4
	exp_a.current_xp = 85
	exp_a.available_skill_points = 2
	
	var data: Dictionary = exp_a.serialize()
	
	var exp_b: ExperienceManager = ExperienceManager.new()
	exp_b.deserialize(data)
	
	var passed: bool = (exp_b.current_level == 4) and (exp_b.current_xp == 85) and (exp_b.available_skill_points == 2)
	exp_a.free()
	exp_b.free()
	return {"name": "Persistence: Serialization Roundtrip", "passed": passed, "message": "Progression restored accurately"}
