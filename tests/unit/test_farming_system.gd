class_name TestFarmingSystem
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_crop_database_lookup())
	results.append(_test_farm_plot_growth_and_watering())
	results.append(_test_farm_plot_harvesting())
	return results

func _test_crop_database_lookup() -> Dictionary:
	var def: CropDefinition = CropDatabase.get_crop(&"crop_wheat")
	var passed: bool = (def != null) and (def.harvest_item_id == &"wheat") and (def.growth_stages == 3)
	return {"name": "Farming: Crop Database Lookup", "passed": passed, "message": "Crop definition valid"}

func _test_farm_plot_growth_and_watering() -> Dictionary:
	var plot: FarmPlot = FarmPlot.new()
	plot._ready()
	
	plot.plant_crop(&"crop_wheat")
	var initial_state: bool = (plot.current_state == FarmPlot.PlotState.GROWING) and plot.is_watered
	
	# Simulate 12 seconds with 2x watered speed -> advances 4 stages -> MATURE
	plot._process(12.0)
	var mature_state: bool = (plot.current_state == FarmPlot.PlotState.MATURE)
	
	var passed: bool = initial_state and mature_state
	plot.free()
	return {"name": "Farming: Plot Growth & Watering Acceleration", "passed": passed, "message": "Crop matured to harvest stage"}

func _test_farm_plot_harvesting() -> Dictionary:
	var plot: FarmPlot = FarmPlot.new()
	plot._ready()
	plot.plant_crop(&"crop_wheat")
	plot._process(20.0) # Fully mature
	
	var p_ctrl: PlayerController = PlayerController.new()
	var inv: InventoryContainer = InventoryContainer.new(10)
	p_ctrl.inventory = inv
	
	plot._harvest(p_ctrl)
	var wheat_count: int = inv.get_item_count(&"wheat")
	var is_empty_again: bool = (plot.current_state == FarmPlot.PlotState.EMPTY)
	
	var passed: bool = (wheat_count >= 2) and is_empty_again
	var msg: String = "Harvested %d wheat, plot state: %d" % [wheat_count, plot.current_state]
	
	plot.free()
	inv.free()
	p_ctrl.free()
	return {"name": "Farming: Harvest Yield & Plot Reset", "passed": passed, "message": msg}
