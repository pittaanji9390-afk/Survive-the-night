class_name TestTimeManager
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_time_progression())
	results.append(_test_day_rollover())
	results.append(_test_day_phase_calculation())
	return results

func _test_time_progression() -> Dictionary:
	var tm: TimeManagerService = TimeManagerService.new()
	tm.set_time(8.0)
	tm.advance_time(1.5) # 8.0 + 1.5 = 9.5 -> 09:30
	var passed: bool = is_equal_approx(tm.current_hour, 9.5) and (tm.current_minute == 30)
	var msg: String = "Expected 09:30, got hour %f min %d" % [tm.current_hour, tm.current_minute]
	tm.free()
	return {"name": "TimeManager: Time Progression", "passed": passed, "message": msg}

func _test_day_rollover() -> Dictionary:
	var tm: TimeManagerService = TimeManagerService.new()
	tm.current_day = 1
	tm.set_time(23.0)
	tm.advance_time(2.0) # 23 + 2 = 25 -> 1.0 next day
	var passed: bool = (tm.current_day == 2) and is_equal_approx(tm.current_hour, 1.0)
	var msg: String = "Expected Day 2 Hour 1.0, got Day %d Hour %f" % [tm.current_day, tm.current_hour]
	tm.free()
	return {"name": "TimeManager: Day Rollover", "passed": passed, "message": msg}

func _test_day_phase_calculation() -> Dictionary:
	var tm: TimeManagerService = TimeManagerService.new()
	tm.set_time(8.0)
	var is_morning: bool = (tm.current_phase == TimeManagerService.DayPhase.MORNING)
	tm.set_time(14.0)
	var is_day: bool = (tm.current_phase == TimeManagerService.DayPhase.DAY)
	tm.set_time(19.0)
	var is_sunset: bool = (tm.current_phase == TimeManagerService.DayPhase.SUNSET)
	tm.set_time(22.0)
	var is_night: bool = (tm.current_phase == TimeManagerService.DayPhase.NIGHT)
	var passed: bool = is_morning and is_day and is_sunset and is_night
	var msg: String = "Morning:%s Day:%s Sunset:%s Night:%s" % [is_morning, is_day, is_sunset, is_night]
	tm.free()
	return {"name": "TimeManager: Phase Calculation", "passed": passed, "message": msg}
