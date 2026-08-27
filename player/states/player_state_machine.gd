class_name PlayerStateMachine
extends Node

enum PlayerState {
	IDLE,
	MOVE,
	SPRINT,
	ATTACK,
	HURT,
	DEAD,
	INTERACTING
}

signal state_changed(old_state: PlayerState, new_state: PlayerState)

var current_state: PlayerState = PlayerState.IDLE
var state_time: float = 0.0

func _physics_process(delta: float) -> void:
	state_time += delta

func transition_to(new_state: PlayerState) -> bool:
	if current_state == new_state:
		return false
	
	if current_state == PlayerState.DEAD:
		# Can only exit dead state through respawn
		return false
	
	var old: PlayerState = current_state
	current_state = new_state
	state_time = 0.0
	
	state_changed.emit(old, new_state)
	return true

func is_state(s: PlayerState) -> bool:
	return current_state == s

func can_move() -> bool:
	return current_state != PlayerState.DEAD and current_state != PlayerState.HURT

func can_attack() -> bool:
	return current_state == PlayerState.IDLE or current_state == PlayerState.MOVE or current_state == PlayerState.SPRINT

func can_interact() -> bool:
	return current_state != PlayerState.DEAD and current_state != PlayerState.HURT

func get_state_name() -> String:
	match current_state:
		PlayerState.IDLE: return "IDLE"
		PlayerState.MOVE: return "MOVE"
		PlayerState.SPRINT: return "SPRINT"
		PlayerState.ATTACK: return "ATTACK"
		PlayerState.HURT: return "HURT"
		PlayerState.DEAD: return "DEAD"
		PlayerState.INTERACTING: return "INTERACTING"
	return "UNKNOWN"
