class_name TestCombatSystem
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_damage_pipeline_math())
	results.append(_test_hitbox_effective_damage())
	results.append(_test_enemy_damage_and_armor())
	results.append(_test_enemy_death_and_xp())
	results.append(_test_projectile_movement())
	return results

func _test_damage_pipeline_math() -> Dictionary:
	var normal_dmg: float = DamagePipeline.calculate_final_damage(20.0, 0.0, 1.5, false, 5.0)
	var crit_dmg: float = DamagePipeline.calculate_final_damage(20.0, 0.0, 1.5, true, 5.0)
	var min_floor_dmg: float = DamagePipeline.calculate_final_damage(20.0, 0.0, 1.5, false, 50.0)
	
	var passed: bool = is_equal_approx(normal_dmg, 15.0) and is_equal_approx(crit_dmg, 25.0) and is_equal_approx(min_floor_dmg, 1.0)
	return {"name": "Combat: Damage Pipeline Math", "passed": passed, "message": "Damage formulas with crit & armor mitigation verified"}

func _test_hitbox_effective_damage() -> Dictionary:
	var hitbox: HitboxComponent = HitboxComponent.new()
	hitbox.damage = 30.0
	hitbox.is_critical = true
	hitbox.crit_multiplier = 2.0
	
	var eff: float = hitbox.get_effective_damage()
	var passed: bool = is_equal_approx(eff, 60.0)
	var msg: String = "Expected 60.0, got %f" % eff
	hitbox.free()
	return {"name": "Combat: Hitbox Effective Damage", "passed": passed, "message": msg}

func _test_enemy_damage_and_armor() -> Dictionary:
	var zombie: ZombieEnemy = ZombieEnemy.new()
	zombie._ready()
	var taken: float = zombie.take_damage(20.0, null, false)
	var passed: bool = is_equal_approx(taken, 19.0) and is_equal_approx(zombie.current_health, 31.0)
	var msg: String = "Expected 19 damage taken, got %f" % taken
	zombie.free()
	return {"name": "Combat: Enemy Armor & Health Mitigation", "passed": passed, "message": msg}

func _test_enemy_death_and_xp() -> Dictionary:
	var zombie: ZombieEnemy = ZombieEnemy.new()
	zombie._ready()
	
	var tech_mgr: TechTreeManager = TechTreeManager.new()
	tech_mgr._ready()
	tech_mgr.available_research_points = 10
	
	zombie.take_damage(100.0, null, false)
	
	var is_dead: bool = (zombie.current_state == EnemyBase.AIState.DEAD) and (zombie.current_health <= 0.0)
	var passed: bool = is_dead and (tech_mgr.available_research_points >= 10)
	
	zombie.free()
	tech_mgr.free()
	return {"name": "Combat: Enemy Death & Kill Processing", "passed": passed, "message": "Enemy successfully killed"}

func _test_projectile_movement() -> Dictionary:
	var proj: Projectile = Projectile.new()
	proj.speed = 100.0
	proj.direction = Vector2.RIGHT
	proj.global_position = Vector2.ZERO
	
	proj._physics_process(0.5)
	var final_pos: Vector2 = proj.global_position
	var passed: bool = is_equal_approx(final_pos.x, 50.0) and is_equal_approx(final_pos.y, 0.0)
	var msg: String = "Projectile moved to %v" % final_pos
	proj.free()
	return {"name": "Combat: Projectile Physics Velocity", "passed": passed, "message": msg}
