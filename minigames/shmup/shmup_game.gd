class_name ShmupGame
extends RefCounted

signal ship_destroyed(lives_remaining: int)
signal bomb_detonated()
signal score_updated(score: int)

var player_lives: int = 3
var bombs: int = 2
var score: int = 0
var multiplier: int = 1
var weapon_level: int = 1

func destroy_enemy(enemy_type: String) -> int:
	var pts: int = 100
	match enemy_type:
		"scout": pts = 100
		"cruiser": pts = 300
		"mothership": pts = 1000
	
	var awarded: int = pts * multiplier
	score += awarded
	score_updated.emit(score)
	return awarded

func take_ship_hit() -> bool:
	player_lives -= 1
	multiplier = 1
	ship_destroyed.emit(player_lives)
	return player_lives > 0

func use_bomb() -> bool:
	if bombs > 0:
		bombs -= 1
		score += 500
		bomb_detonated.emit()
		return true
	return false
