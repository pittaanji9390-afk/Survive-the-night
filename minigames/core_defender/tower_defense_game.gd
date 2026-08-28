class_name TowerDefenseGame
extends RefCounted

signal core_damaged(hp: float)
signal wave_started(wave_idx: int)
signal td_game_over(victory: bool, score: int)

var core_hp: float = 100.0
var gold: int = 150
var current_wave: int = 0
var total_waves: int = 10
var placed_turrets: Array[Dictionary] = []
var creeps_killed: int = 0

func build_turret(turret_type: String, grid_pos: Vector2i) -> bool:
	var cost: int = 50
	var dps: float = 20.0
	
	match turret_type:
		"arrow_turret":
			cost = 50
			dps = 20.0
		"frost_tower":
			cost = 75
			dps = 15.0
		"tesla_coil":
			cost = 120
			dps = 45.0
	
	if gold >= cost:
		gold -= cost
		placed_turrets.append({ "type": turret_type, "pos": grid_pos, "dps": dps, "level": 1 })
		return true
	return false

func start_next_wave() -> void:
	if current_wave < total_waves:
		current_wave += 1
		wave_started.emit(current_wave)

func kill_creep(reward_gold: int = 15) -> void:
	gold += reward_gold
	creeps_killed += 1

func damage_core(amount: float) -> void:
	core_hp = maxf(0.0, core_hp - amount)
	core_damaged.emit(core_hp)
	if core_hp <= 0.0:
		td_game_over.emit(false, get_score())

func get_score() -> int:
	return (current_wave * 200) + (creeps_killed * 30) + int(core_hp * 5)
