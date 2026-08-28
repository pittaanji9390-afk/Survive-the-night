class_name TestVehiclesAndTrains
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_locomotive_acceleration_and_fuel())
	return results

func _test_locomotive_acceleration_and_fuel() -> Dictionary:
	var loco: LocomotiveEntity = LocomotiveEntity.new()
	loco._ready()
	loco.coal_fuel_units = 5.0
	
	loco.update_locomotive(2.0, true) # Throttle on
	
	var has_sped_up: bool = loco.current_speed > 50.0
	var burned_fuel: bool = loco.coal_fuel_units < 5.0
	
	var passed: bool = has_sped_up and burned_fuel
	loco.free()
	return {"name": "Vehicles: Steam Locomotive Physics & Fuel Burning", "passed": passed, "message": "Accelerated with coal consumption"}
