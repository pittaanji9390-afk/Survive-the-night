class_name TestFactoryAutomation
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_auto_smelter_processing())
	return results

func _test_auto_smelter_processing() -> Dictionary:
	var smelter: AutoSmelterStructure = AutoSmelterStructure.new()
	smelter._ready()
	
	smelter.internal_ore_storage = 5
	smelter.internal_ingot_storage = 0
	smelter.power_comp.is_powered = true
	
	# Process 3.0 seconds (interval is 3.0s) -> should smelt 1 ore
	smelter._process(3.1)
	
	var passed: bool = (smelter.internal_ore_storage == 4) and (smelter.internal_ingot_storage == 1)
	smelter.free()
	return {"name": "Automation: Auto Smelter Ingot Production", "passed": passed, "message": "Smelted 1 ore -> 1 ingot"}
