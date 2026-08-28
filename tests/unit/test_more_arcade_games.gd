class_name TestMoreArcadeGames
extends RefCounted

const FishingGameClass = preload("res://minigames/fishing/fishing_game.gd")
const MinerGameClass = preload("res://minigames/miner/miner_game.gd")
const ShmupGameClass = preload("res://minigames/shmup/shmup_game.gd")

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_fishing_tension_and_reel())
	results.append(_test_miner_drilling_and_sales())
	results.append(_test_shmup_score_and_bombs())
	return results

func _test_fishing_tension_and_reel() -> Dictionary:
	var fish_game = FishingGameClass.new()
	fish_game.hook_fish("Golden Dorado", 30.0, 300)
	
	# Reel for 0.4s (tension: 0.5 + 0.14 = 0.64, inside sweet spot)
	fish_game.update_reel(0.4, true)
	
	var passed: bool = (fish_game.distance_to_boat < 30.0) and (fish_game.line_tension >= 0.4 and fish_game.line_tension <= 0.75)
	return {"name": "Arcade: Deep Sea Fishing Tension Reeling", "passed": passed, "message": "Reeled distance: %f, tension: %f" % [fish_game.distance_to_boat, fish_game.line_tension]}

func _test_miner_drilling_and_sales() -> Dictionary:
	var miner = MinerGameClass.new()
	miner.drill_down(2)
	
	# Clear and explicitly test sales calculation
	miner.cargo_hold.clear()
	miner.cargo_hold.append("Ruby")
	miner.cargo_hold.append("Diamond")
	
	var sold_val: int = miner.return_to_surface_and_sell() # 100 + 200 = 300
	
	var passed: bool = (sold_val == 300) and (miner.miner_gold == 300) and miner.cargo_hold.is_empty()
	return {"name": "Arcade: Subterranean Miner Excavation & Refinery", "passed": passed, "message": "Sold Ruby & Diamond for 300 gold"}

func _test_shmup_score_and_bombs() -> Dictionary:
	var shmup = ShmupGameClass.new()
	shmup.multiplier = 2
	shmup.destroy_enemy("cruiser") # 300 * 2 = 600
	
	var bombed: bool = shmup.use_bomb() # +500
	
	var passed: bool = bombed and (shmup.score == 1100) and (shmup.bombs == 1)
	return {"name": "Arcade: Star Void Invader Multiplier & Nova Bomb", "passed": passed, "message": "Score: 1100 with 1 bomb remaining"}
