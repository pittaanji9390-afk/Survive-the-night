class_name TestNavalSystems
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_boat_boarding_and_speed())
	results.append(_test_hull_damage_and_sinking())
	return results

func _test_boat_boarding_and_speed() -> Dictionary:
	var boat: BoatEntity = BoatEntity.new()
	boat._ready()
	
	var player: PlayerController = PlayerController.new()
	var stats: PlayerStats = PlayerStats.new()
	stats._ready()
	player.stats = stats
	
	var base_spd: float = stats.speed.get_max_value()
	boat.board_boat(player)
	var sailing_spd: float = stats.speed.get_max_value()
	
	boat.disembark_boat(player)
	var land_spd: float = stats.speed.get_max_value()
	
	var passed: bool = (sailing_spd == base_spd + 80.0) and (land_spd == base_spd)
	stats.free()
	player.free()
	boat.free()
	return {"name": "Naval: Boat Boarding & Sailing Speed", "passed": passed, "message": "Speed boosted on water: %f -> %f" % [base_spd, sailing_spd]}

func _test_hull_damage_and_sinking() -> Dictionary:
	var boat: BoatEntity = BoatEntity.new()
	boat._ready()
	boat.take_hull_damage(350.0)
	
	var passed: bool = (boat.current_hull_hp == 0.0)
	boat.free()
	return {"name": "Naval: Hull Damage Mitigation & Shipwreck", "passed": passed, "message": "Hull depleted and vessel sunk"}
