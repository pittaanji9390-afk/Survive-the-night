class_name TestSeasonsAndWeather
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_season_progression())
	results.append(_test_seasonal_temperature_offsets())
	return results

func _test_season_progression() -> Dictionary:
	var mgr: SeasonManager = SeasonManager.new()
	mgr.days_per_season = 5
	
	# Day 1 -> Spring
	mgr._on_day_started(1)
	var is_spring: bool = (mgr.current_season == SeasonManager.SeasonType.SPRING)
	
	# Day 6 -> Summer
	mgr._on_day_started(6)
	var is_summer: bool = (mgr.current_season == SeasonManager.SeasonType.SUMMER)
	
	# Day 11 -> Autumn
	mgr._on_day_started(11)
	var is_autumn: bool = (mgr.current_season == SeasonManager.SeasonType.AUTUMN)
	
	# Day 16 -> Winter
	mgr._on_day_started(16)
	var is_winter: bool = (mgr.current_season == SeasonManager.SeasonType.WINTER)
	
	var passed: bool = is_spring and is_summer and is_autumn and is_winter
	mgr.free()
	return {"name": "Seasons: 4-Season Cycle Progression", "passed": passed, "message": "Spring -> Summer -> Autumn -> Winter verified"}

func _test_seasonal_temperature_offsets() -> Dictionary:
	var mgr: SeasonManager = SeasonManager.new()
	mgr.current_season = SeasonManager.SeasonType.SUMMER
	var summer_mod: float = mgr.get_temperature_modifier()
	
	mgr.current_season = SeasonManager.SeasonType.WINTER
	var winter_mod: float = mgr.get_temperature_modifier()
	
	var passed: bool = (summer_mod > 0.0) and (winter_mod < 0.0)
	mgr.free()
	return {"name": "Seasons: Dynamic Temperature Offsets", "passed": passed, "message": "Summer: +%f, Winter: %f" % [summer_mod, winter_mod]}
