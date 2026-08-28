class_name TestTitanWorldBoss
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_titan_phases())
	return results

func _test_titan_phases() -> Dictionary:
	var boss: PyroclasticTitanBoss = PyroclasticTitanBoss.new()
	boss._ready()
	
	var is_p1: bool = (boss.current_titan_phase == PyroclasticTitanBoss.TitanPhase.PHASE_1_CRUST)
	
	# Damage to 50% (425 HP) -> triggers Meteor Storm (Phase 2)
	boss.take_damage(425.0, null, false)
	var is_p2: bool = (boss.current_titan_phase == PyroclasticTitanBoss.TitanPhase.PHASE_2_METEOR_STORM)
	
	# Damage to 20% (170 HP) -> triggers Supernova (Phase 3)
	boss.take_damage(260.0, null, false)
	var is_p3: bool = (boss.current_titan_phase == PyroclasticTitanBoss.TitanPhase.PHASE_3_SUPERNOVA)
	
	var passed: bool = is_p1 and is_p2 and is_p3
	boss.free()
	return {"name": "World Boss: Pyroclastic Titan 3-Phase Metamorphosis", "passed": passed, "message": "Crust -> Meteor Storm -> Supernova verified"}
