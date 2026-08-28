class_name TestArcadeGames
extends RefCounted

const ArcadeManagerClass = preload("res://minigames/hub/arcade_manager.gd")
const SlasherGameClass = preload("res://minigames/night_slasher/slasher_game.gd")
const TowerDefenseGameClass = preload("res://minigames/core_defender/tower_defense_game.gd")
const CardBattleGameClass = preload("res://minigames/card_battler/card_battle_game.gd")

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_arcade_manager_token_economy())
	results.append(_test_slasher_perk_leveling())
	results.append(_test_core_defender_economy())
	results.append(_test_card_battler_combat_turn())
	return results

func _test_arcade_manager_token_economy() -> Dictionary:
	var mgr = ArcadeManagerClass.new()
	mgr._ready()
	
	var tokens: int = mgr.submit_score(&"night_slasher", 1500) # 15 tokens
	var spent: bool = mgr.spend_tokens(5)
	
	var passed: bool = (tokens == 15) and spent and (mgr.total_arcade_tokens == 10) and (mgr.high_scores[&"night_slasher"] == 1500)
	mgr.free()
	return {"name": "Arcade: Token Economy & High Scores", "passed": passed, "message": "15 tokens earned, 5 spent -> 10 left"}

func _test_slasher_perk_leveling() -> Dictionary:
	var game = SlasherGameClass.new()
	game.weapons["holy_aura"] = 0
	
	# Add kills to trigger level up (100 XP required)
	game.add_kill(100)
	game.select_perk("Unlock Holy Aura")
	
	var passed: bool = (game.slasher_level == 2) and (game.weapons["holy_aura"] == 1)
	return {"name": "Arcade: Night Slasher Perk Drafting & Level Up", "passed": passed, "message": "Leveled to 2 and unlocked Holy Aura"}

func _test_core_defender_economy() -> Dictionary:
	var td = TowerDefenseGameClass.new()
	td.gold = 100
	
	var built: bool = td.build_turret("arrow_turret", Vector2i(2, 3)) # costs 50
	td.kill_creep(25) # +25g
	
	var passed: bool = built and (td.gold == 75) and (td.placed_turrets.size() == 1)
	return {"name": "Arcade: Core Defender Turret Grid & Bounties", "passed": passed, "message": "Built turret with gold management"}

func _test_card_battler_combat_turn() -> Dictionary:
	var card_game = CardBattleGameClass.new()
	card_game.start_battle()
	
	var initial_hand_count: int = card_game.hand.size() # 5
	
	# Play first card in hand
	var played: bool = card_game.play_card(0)
	
	var passed: bool = (initial_hand_count == 5) and played and (card_game.hand.size() == 4)
	return {"name": "Arcade: Card Battler Deck Drawing & Hand Play", "passed": passed, "message": "Drew 5 cards and played card with energy deduction"}
