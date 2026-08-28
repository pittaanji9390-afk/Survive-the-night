class_name TestSurvivalMechanics
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_status_effect_lifecycle())
	results.append(_test_thirst_attribute())
	results.append(_test_temperature_warming_and_freezing())
	return results

func _test_status_effect_lifecycle() -> Dictionary:
	var stats: PlayerStats = PlayerStats.new()
	stats._ready()
	
	var eff: StatusEffect = StatusEffect.new()
	eff.effect_id = &"test_poison"
	eff.duration_sec = 2.0
	eff.tick_interval_sec = 0.5
	eff.damage_per_tick = 5.0
	
	# Simulate 1.0s -> 2 ticks (10 damage)
	var finished_mid: bool = eff.update_effect(1.0, stats)
	var hp_mid: float = stats.health.get_current_value()
	
	# Simulate 1.5s -> completes
	var finished_end: bool = eff.update_effect(1.5, stats)
	
	var passed: bool = (not finished_mid) and (hp_mid == 90.0) and finished_end
	stats.free()
	return {"name": "Survival: Status Effect Lifecycle & Damage Ticks", "passed": passed, "message": "HP mid: %f, Finished: %s" % [hp_mid, finished_end]}

func _test_thirst_attribute() -> Dictionary:
	var thirst: ThirstAttribute = ThirstAttribute.new()
	thirst.current_thirst = 100.0
	
	thirst.update_thirst(10.0, true, 20.0, null) # Drains with sprint
	var drained_thirst: float = thirst.current_thirst
	
	thirst.drink(25.0)
	var restored_thirst: float = thirst.current_thirst
	
	var passed: bool = (drained_thirst < 100.0) and (restored_thirst > drained_thirst)
	return {"name": "Survival: Thirst Drain & Hydration", "passed": passed, "message": "Drained to %f, restored to %f" % [drained_thirst, restored_thirst]}

func _test_temperature_warming_and_freezing() -> Dictionary:
	var temp_mgr: TemperatureManager = TemperatureManager.new()
	temp_mgr._ready()
	
	temp_mgr.ambient_temperature = -10.0 # Extreme winter night
	temp_mgr._update_body_temperature(20.0) # Pulls body temp down
	
	var cold_body_temp: float = temp_mgr.current_body_temperature
	var is_below_threshold: bool = (cold_body_temp <= temp_mgr.freezing_threshold)
	
	temp_mgr.free()
	return {"name": "Survival: Body Temperature & Hypothermia", "passed": is_below_threshold, "message": "Body temp: %f°C (Freezing: %s)" % [cold_body_temp, is_below_threshold]}
