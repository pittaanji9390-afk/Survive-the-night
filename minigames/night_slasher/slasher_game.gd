class_name SlasherGame
extends RefCounted

signal slasher_level_up(new_lvl: int, offered_perks: Array[String])
signal slasher_game_over(final_score: int)

var survival_timer_sec: float = 0.0
var kill_count: int = 0
var slasher_level: int = 1
var slasher_xp: int = 0
var xp_to_next_level: int = 100

var weapons: Dictionary = {
	"orbiting_blades": 1,
	"holy_aura": 0,
	"lightning_strike": 0
}

var max_hp: float = 100.0
var current_hp: float = 100.0
var is_game_active: bool = true

func update_game(delta: float) -> void:
	if not is_game_active:
		return
	
	survival_timer_sec += delta

func add_kill(xp_gained: int = 25) -> void:
	if not is_game_active:
		return
	
	kill_count += 1
	slasher_xp += xp_gained
	if slasher_xp >= xp_to_next_level:
		_level_up()

func _level_up() -> void:
	slasher_level += 1
	slasher_xp -= xp_to_next_level
	xp_to_next_level = int(xp_to_next_level * 1.5)
	
	var perks: Array[String] = ["Upgrade Orbiting Blades", "Unlock Holy Aura", "Unlock Lightning Strike"]
	slasher_level_up.emit(slasher_level, perks)

func select_perk(perk_name: String) -> void:
	match perk_name:
		"Upgrade Orbiting Blades":
			weapons["orbiting_blades"] += 1
		"Unlock Holy Aura":
			weapons["holy_aura"] += 1
		"Unlock Lightning Strike":
			weapons["lightning_strike"] += 1

func get_final_score() -> int:
	return int((survival_timer_sec * 10.0) + (kill_count * 50))
