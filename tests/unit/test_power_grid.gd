class_name TestPowerGrid
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_generation_and_demand_balance())
	results.append(_test_battery_charge_and_discharge())
	results.append(_test_blackout_state())
	return results

func _test_generation_and_demand_balance() -> Dictionary:
	var mgr: PowerGridManager = PowerGridManager.new()
	mgr._ready()
	
	var gen: PowerComponent = PowerComponent.new()
	gen.power_type = PowerComponent.PowerType.PRODUCER
	gen.wattage = 100.0
	mgr.register_component(gen)
	
	var load_comp: PowerComponent = PowerComponent.new()
	load_comp.power_type = PowerComponent.PowerType.CONSUMER
	load_comp.wattage = 40.0
	mgr.register_component(load_comp)
	
	mgr.update_power_tick(1.0)
	
	var passed: bool = (mgr.total_generation == 100.0) and (mgr.total_demand == 40.0) and load_comp.is_powered
	
	gen.free()
	load_comp.free()
	mgr.free()
	return {"name": "Power: Generation & Demand Balance", "passed": passed, "message": "100W Gen vs 40W Demand powered successfully"}

func _test_battery_charge_and_discharge() -> Dictionary:
	var mgr: PowerGridManager = PowerGridManager.new()
	mgr._ready()
	
	# Battery 500J capacity, starts empty
	var bat: PowerComponent = PowerComponent.new()
	bat.power_type = PowerComponent.PowerType.STORAGE
	bat.max_storage_capacity = 500.0
	bat.current_stored_joules = 0.0
	mgr.register_component(bat)
	
	# Producer 50W, no consumers -> surplus 50W * 2s = 100J stored
	var gen: PowerComponent = PowerComponent.new()
	gen.power_type = PowerComponent.PowerType.PRODUCER
	gen.wattage = 50.0
	mgr.register_component(gen)
	
	mgr.update_power_tick(2.0)
	var charged_ok: bool = is_equal_approx(bat.current_stored_joules, 100.0)
	
	# Turn off producer, add 20W consumer -> deficit 20W * 3s = 60J discharged -> 40J remaining
	gen.is_active = false
	var load_comp: PowerComponent = PowerComponent.new()
	load_comp.power_type = PowerComponent.PowerType.CONSUMER
	load_comp.wattage = 20.0
	mgr.register_component(load_comp)
	
	mgr.update_power_tick(3.0)
	var discharged_ok: bool = is_equal_approx(bat.current_stored_joules, 40.0) and load_comp.is_powered
	
	var passed: bool = charged_ok and discharged_ok
	
	gen.free()
	load_comp.free()
	bat.free()
	mgr.free()
	return {"name": "Power: Battery Charging & Discharging", "passed": passed, "message": "Charged to 100J, discharged to 40J"}

func _test_blackout_state() -> Dictionary:
	var mgr: PowerGridManager = PowerGridManager.new()
	mgr._ready()
	
	# Consumer with no generation and no battery -> immediate blackout
	var load_comp: PowerComponent = PowerComponent.new()
	load_comp.power_type = PowerComponent.PowerType.CONSUMER
	load_comp.wattage = 50.0
	mgr.register_component(load_comp)
	
	mgr.update_power_tick(1.0)
	
	var passed: bool = (not load_comp.is_powered) and mgr.is_in_blackout
	
	load_comp.free()
	mgr.free()
	return {"name": "Power: Blackout on Deficit", "passed": passed, "message": "Consumer unpowered during blackout"}
