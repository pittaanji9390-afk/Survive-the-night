class_name TestFluidLogistics
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_tank_fluid_storage_and_drain())
	results.append(_test_fluid_mixing_guard())
	return results

func _test_tank_fluid_storage_and_drain() -> Dictionary:
	var tank: FluidTankStructure = FluidTankStructure.new()
	tank._ready()
	
	var added: float = tank.add_fluid(FluidTankStructure.FluidType.WATER, 200.0)
	var drained: float = tank.drain_fluid(50.0)
	
	var passed: bool = (added == 200.0) and (drained == 50.0) and (tank.current_fluid_liters == 150.0)
	tank.free()
	return {"name": "Fluids: Tank Storage & Drainage Math", "passed": passed, "message": "Stored 200L, drained 50L -> 150L"}

func _test_fluid_mixing_guard() -> Dictionary:
	var tank: FluidTankStructure = FluidTankStructure.new()
	tank._ready()
	
	tank.add_fluid(FluidTankStructure.FluidType.WATER, 100.0)
	var oil_added: float = tank.add_fluid(FluidTankStructure.FluidType.CRUDE_OIL, 50.0)
	
	var passed: bool = (oil_added == 0.0) and (tank.current_fluid_liters == 100.0)
	tank.free()
	return {"name": "Fluids: Fluid Type Separation Guard", "passed": passed, "message": "Prevented mixing oil into water tank"}
