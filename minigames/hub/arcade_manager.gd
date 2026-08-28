class_name ArcadeManager
extends Node

signal arcade_tokens_changed(current_tokens: int)
signal mini_game_completed(game_id: StringName, high_score: int, tokens_awarded: int)

var total_arcade_tokens: int = 0
var high_scores: Dictionary = {
	&"night_slasher": 0,
	&"core_defender": 0,
	&"card_battler": 0,
	&"subterranean_miner": 0
}

func _ready() -> void:
	ServiceLocator.register_service(&"ArcadeManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"ArcadeManager")

func submit_score(game_id: StringName, score: int) -> int:
	var tokens: int = int(score / 100.0)
	total_arcade_tokens += tokens
	
	if score > high_scores.get(game_id, 0):
		high_scores[game_id] = score
	
	arcade_tokens_changed.emit(total_arcade_tokens)
	mini_game_completed.emit(game_id, high_scores[game_id], tokens)
	EventBus.notification_posted.emit("Arcade Victory!", "Won %d Tokens! (High Score: %d)" % [tokens, high_scores[game_id]], "coin")
	return tokens

func spend_tokens(amount: int) -> bool:
	if total_arcade_tokens >= amount:
		total_arcade_tokens -= amount
		arcade_tokens_changed.emit(total_arcade_tokens)
		return true
	return false
