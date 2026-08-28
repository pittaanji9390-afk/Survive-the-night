class_name TestTechTree
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_tech_prerequisite_graph())
	results.append(_test_tech_unlock_and_point_deduction())
	results.append(_test_tech_serialization())
	return results

func _test_tech_prerequisite_graph() -> Dictionary:
	var mgr: TechTreeManager = TechTreeManager.new()
	mgr._ready()
	mgr.available_research_points = 50
	
	# Primitive Archery requires Stone Age
	var cannot_unlock_archery: bool = not mgr.can_unlock_tech(&"tech_archery")
	
	# Unlock prerequisite Stone Age first
	mgr.unlock_tech(&"tech_stone_age")
	var can_now_unlock_archery: bool = mgr.can_unlock_tech(&"tech_archery")
	
	var passed: bool = cannot_unlock_archery and can_now_unlock_archery
	mgr.free()
	return {"name": "TechTree: Prerequisite Dependency Graph", "passed": passed, "message": "Dependency graph resolved properly"}

func _test_tech_unlock_and_point_deduction() -> Dictionary:
	var mgr: TechTreeManager = TechTreeManager.new()
	mgr._ready()
	mgr.available_research_points = 20
	
	# Stone Age costs 5 points
	var unlocked: bool = mgr.unlock_tech(&"tech_stone_age")
	var passed: bool = unlocked and (mgr.available_research_points == 15) and mgr.is_tech_unlocked(&"tech_stone_age")
	mgr.free()
	return {"name": "TechTree: Unlock & Research Point Deduction", "passed": passed, "message": "Points remaining: 15"}

func _test_tech_serialization() -> Dictionary:
	var mgr_a: TechTreeManager = TechTreeManager.new()
	mgr_a._ready()
	mgr_a.available_research_points = 45
	mgr_a.unlock_tech(&"tech_stone_age")
	mgr_a.unlock_tech(&"tech_tanning")
	
	var data: Dictionary = mgr_a.serialize()
	
	var mgr_b: TechTreeManager = TechTreeManager.new()
	mgr_b._ready()
	mgr_b.deserialize(data)
	
	var passed: bool = (mgr_b.available_research_points == mgr_a.available_research_points) and mgr_b.is_tech_unlocked(&"tech_stone_age") and mgr_b.is_tech_unlocked(&"tech_tanning")
	
	mgr_a.free()
	mgr_b.free()
	return {"name": "TechTree: Serialization & Deserialization", "passed": passed, "message": "Saved and restored accurately"}
