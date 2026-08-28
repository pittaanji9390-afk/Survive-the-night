class_name TestWaveManager
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_threat_budget_calculation())
	results.append(_test_blood_moon_multiplier())
	results.append(_test_grid_pathfinder_navigation())
	return results

func _test_threat_budget_calculation() -> Dictionary:
	var wave_mgr: WaveManager = WaveManager.new()
	wave_mgr._ready()
	
	# Day 1: 10 + 5 = 15 threat
	var day1_threat: int = wave_mgr.calculate_threat_budget(1)
	# Day 3: 10 + 15 = 25 threat
	var day3_threat: int = wave_mgr.calculate_threat_budget(3)
	
	var passed: bool = (day1_threat == 15) and (day3_threat == 25)
	wave_mgr.free()
	return {"name": "Waves: Threat Budget Progression", "passed": passed, "message": "Day 1: %d, Day 3: %d" % [day1_threat, day3_threat]}

func _test_blood_moon_multiplier() -> Dictionary:
	var wave_mgr: WaveManager = WaveManager.new()
	wave_mgr._ready()
	
	# Day 5 (Blood Moon): (10 + 25) * 2 = 70 threat
	var day5_threat: int = wave_mgr.calculate_threat_budget(5)
	var passed: bool = (day5_threat == 70)
	wave_mgr.free()
	return {"name": "Waves: Blood Moon Threat Spike", "passed": passed, "message": "Day 5 Blood Moon Threat: %d" % day5_threat}

func _test_grid_pathfinder_navigation() -> Dictionary:
	var pathfinder: GridPathfinder = GridPathfinder.new()
	pathfinder.grid_width = 20
	pathfinder.grid_height = 20
	pathfinder.cell_size = 32
	pathfinder._ready()
	
	var path: PackedVector2Array = pathfinder.find_path_world(Vector2(0, 0), Vector2(64, 0))
	var passed: bool = (path.size() >= 2)
	
	pathfinder.free()
	return {"name": "AI: Grid Pathfinder Path Generation", "passed": passed, "message": "Generated path with %d nodes" % path.size()}
