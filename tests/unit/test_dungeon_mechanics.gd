class_name TestDungeonMechanics
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_broodmother_phases())
	results.append(_test_cave_spider_stats())
	return results

func _test_broodmother_phases() -> Dictionary:
	var boss: BroodmotherBoss = BroodmotherBoss.new()
	boss._ready()
	
	var is_p1: bool = (boss.current_brood_phase == BroodmotherBoss.BroodPhase.PHASE_1_WEB_SPINNER)
	
	# Damage to 50% (325 HP) -> triggers Brood Caller (Phase 2)
	boss.take_damage(325.0, null, false)
	var is_p2: bool = (boss.current_brood_phase == BroodmotherBoss.BroodPhase.PHASE_2_BROOD_CALLER)
	
	# Damage to 20% (130 HP) -> triggers Acid Frenzy (Phase 3)
	boss.take_damage(200.0, null, false)
	var is_p3: bool = (boss.current_brood_phase == BroodmotherBoss.BroodPhase.PHASE_3_ACID_FRENZY)
	
	var passed: bool = is_p1 and is_p2 and is_p3
	boss.free()
	return {"name": "Dungeon: Broodmother 3-Phase Metamorphosis", "passed": passed, "message": "Phase transitions verified"}

func _test_cave_spider_stats() -> Dictionary:
	var spider: CaveSpider = CaveSpider.new()
	spider._ready()
	
	var passed: bool = (spider.max_health == 45.0) and (spider.move_speed == 125.0) and (spider.xp_reward == 30)
	spider.free()
	return {"name": "Dungeon: Cave Spider Attributes", "passed": passed, "message": "Spider speed: 125, HP: 45"}
