class_name TestCompanionTaming
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_companion_level_up())
	results.append(_test_mount_speed_boost())
	return results

func _test_companion_level_up() -> Dictionary:
	var comp: TamedCompanionEntity = TamedCompanionEntity.new()
	comp._ready()
	
	var initial_hp: float = comp.max_health # 120
	var initial_dmg: float = comp.attack_damage # 18
	
	comp.level_up()
	
	var passed: bool = (comp.companion_level == 2) and (comp.max_health == initial_hp + 15.0) and (comp.attack_damage == initial_dmg + 3.0)
	comp.free()
	return {"name": "Companions: Level Up & Combat Scaling", "passed": passed, "message": "Companion Level 2 with boosted stats"}

func _test_mount_speed_boost() -> Dictionary:
	var comp: TamedCompanionEntity = TamedCompanionEntity.new()
	comp._ready()
	
	var player: PlayerController = PlayerController.new()
	var stats: PlayerStats = PlayerStats.new()
	stats._ready()
	player.stats = stats
	
	var base_spd: float = stats.speed.get_max_value()
	comp.mount_player(player)
	var mounted_spd: float = stats.speed.get_max_value()
	
	comp.dismount_player(player)
	var dismounted_spd: float = stats.speed.get_max_value()
	
	var passed: bool = (mounted_spd == base_spd + 50.0) and (dismounted_spd == base_spd)
	
	stats.free()
	player.free()
	comp.free()
	return {"name": "Companions: Mount Speed Buff & Dismount", "passed": passed, "message": "Speed boosted from %f to %f" % [base_spd, mounted_spd]}
