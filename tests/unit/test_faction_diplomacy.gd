class_name TestFactionDiplomacy
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_faction_stance_transitions())
	return results

func _test_faction_stance_transitions() -> Dictionary:
	var mgr: FactionManager = FactionManager.new()
	mgr._ready()
	
	var vanguard: FactionDefinition = mgr.get_faction(&"faction_iron_vanguard")
	var initial_stance: bool = (vanguard.get_stance() == FactionDefinition.FactionStance.NEUTRAL)
	
	# Increase rep by +60 -> Allied
	mgr.modify_reputation(&"faction_iron_vanguard", 60)
	var allied_stance: bool = (vanguard.get_stance() == FactionDefinition.FactionStance.ALLIED)
	
	# Drop rep by -100 -> Hostile
	mgr.modify_reputation(&"faction_iron_vanguard", -100)
	var hostile_stance: bool = (vanguard.get_stance() == FactionDefinition.FactionStance.HOSTILE)
	
	var passed: bool = initial_stance and allied_stance and hostile_stance
	mgr.free()
	return {"name": "Factions: Reputation & Diplomatic Stance Shifts", "passed": passed, "message": "Neutral -> Allied -> Hostile transitions verified"}
