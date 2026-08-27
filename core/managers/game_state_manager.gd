class_name GameStateManagerService
extends Node

enum GameState {
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	INVENTORY,
	CRAFTING,
	BUILDING,
	DIALOGUE,
	GAME_OVER,
	VICTORY
}

var current_state: GameState = GameState.PLAYING
var previous_state: GameState = GameState.PLAYING

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_state(new_state: GameState) -> bool:
	if current_state == new_state:
		return false
	
	if not _is_valid_transition(current_state, new_state):
		GameLogger.warn("GameState", "Invalid state transition requested: %s -> %s" % [_state_to_string(current_state), _state_to_string(new_state)])
		return false
	
	var old: GameState = current_state
	previous_state = current_state
	current_state = new_state
	
	_handle_state_effects(old, new_state)
	
	GameLogger.info("GameState", "Transitioned from %s to %s" % [_state_to_string(old), _state_to_string(new_state)])
	EventBus.game_state_changed.emit(int(old), int(new_state))
	return true

func return_to_previous_state() -> bool:
	return change_state(previous_state)

func is_state(state_query: GameState) -> bool:
	return current_state == state_query

func is_gameplay_active() -> bool:
	return current_state == GameState.PLAYING or current_state == GameState.BUILDING

func _is_valid_transition(from_state: GameState, to_state: GameState) -> bool:
	match to_state:
		GameState.GAME_OVER, GameState.VICTORY, GameState.MAIN_MENU:
			return true
		GameState.PAUSED:
			return from_state != GameState.MAIN_MENU and from_state != GameState.LOADING and from_state != GameState.PAUSED
		GameState.INVENTORY, GameState.CRAFTING, GameState.BUILDING, GameState.DIALOGUE:
			return from_state == GameState.PLAYING or from_state == GameState.BUILDING or from_state == GameState.INVENTORY or from_state == GameState.CRAFTING
		GameState.PLAYING:
			return true
		GameState.LOADING:
			return true
	return true

func _handle_state_effects(_old_state: GameState, new_state: GameState) -> void:
	if not is_inside_tree():
		return
	var tree: SceneTree = get_tree()
	if not tree:
		return
	match new_state:
		GameState.PAUSED:
			tree.paused = true
			EventBus.game_paused.emit(true)
		GameState.PLAYING:
			tree.paused = false
			EventBus.game_paused.emit(false)
		GameState.MAIN_MENU, GameState.GAME_OVER, GameState.VICTORY:
			tree.paused = false
			EventBus.game_paused.emit(false)

func _state_to_string(state: GameState) -> String:
	match state:
		GameState.MAIN_MENU: return "MAIN_MENU"
		GameState.LOADING: return "LOADING"
		GameState.PLAYING: return "PLAYING"
		GameState.PAUSED: return "PAUSED"
		GameState.INVENTORY: return "INVENTORY"
		GameState.CRAFTING: return "CRAFTING"
		GameState.BUILDING: return "BUILDING"
		GameState.DIALOGUE: return "DIALOGUE"
		GameState.GAME_OVER: return "GAME_OVER"
		GameState.VICTORY: return "VICTORY"
	return "UNKNOWN"
