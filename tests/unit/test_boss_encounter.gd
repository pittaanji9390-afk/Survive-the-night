class_name TestBossEncounter
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_boss_phase_transitions())
	results.append(_test_boss_defeat())
	return results

func _test_boss_phase_transitions() -> Dictionary:
	var boss: NightTerrorBoss = NightTerrorBoss.new()
	boss._ready()
	
	# Initial: Phase 1 Stalker
	var is_p1: bool = (boss.current_boss_phase == NightTerrorBoss.BossPhase.PHASE_1_STALKER)
	
	# Damage to 50% HP (250 HP left) -> triggers Phase 2
	boss.take_damage(250.0, null, false)
	var is_p2: bool = (boss.current_boss_phase == NightTerrorBoss.BossPhase.PHASE_2_ENRAGED)
	
	# Damage to 20% HP (100 HP left) -> triggers Phase 3
	boss.take_damage(150.0, null, false)
	var is_p3: bool = (boss.current_boss_phase == NightTerrorBoss.BossPhase.PHASE_3_FRENZY)
	
	var passed: bool = is_p1 and is_p2 and is_p3
	boss.free()
	return {"name": "Boss: 3-Phase Multi-Stage Transitions", "passed": passed, "message": "P1 -> P2 -> P3 transitions verified"}

func _test_boss_defeat() -> Dictionary:
	var boss: NightTerrorBoss = NightTerrorBoss.new()
	boss._ready()
	boss.take_damage(600.0, null, false)
	
	var is_dead: bool = (boss.current_state == EnemyBase.AIState.DEAD) and (boss.current_health <= 0.0)
	boss.free()
	return {"name": "Boss: Fatal Damage & Victory", "passed": is_dead, "message": "Boss defeated successfully"}
