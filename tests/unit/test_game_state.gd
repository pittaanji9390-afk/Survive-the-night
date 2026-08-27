class_name TestGameState
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_initial_state())
	results.append(_test_valid_transition())
	results.append(_test_invalid_transition_guard())
	return results

func _test_initial_state() -> Dictionary:
	var gsm: GameStateManagerService = GameStateManagerService.new()
	var state_val: int = gsm.current_state
	var passed: bool = (state_val == GameStateManagerService.GameState.PLAYING)
	var msg: String = "Expected PLAYING, got %d" % state_val
	gsm.free()
	return {"name": "GameStateManager: Initial State", "passed": passed, "message": msg}

func _test_valid_transition() -> Dictionary:
	var gsm: GameStateManagerService = GameStateManagerService.new()
	var changed: bool = gsm.change_state(GameStateManagerService.GameState.PAUSED)
	var is_paused: bool = (gsm.current_state == GameStateManagerService.GameState.PAUSED)
	var resumed: bool = gsm.change_state(GameStateManagerService.GameState.PLAYING)
	var is_playing: bool = (gsm.current_state == GameStateManagerService.GameState.PLAYING)
	var msg: String = "Transitions: %s, %s" % [changed, resumed]
	gsm.free()
	return {"name": "GameStateManager: Valid Transitions", "passed": changed and is_paused and resumed and is_playing, "message": msg}

func _test_invalid_transition_guard() -> Dictionary:
	var gsm: GameStateManagerService = GameStateManagerService.new()
	gsm.current_state = GameStateManagerService.GameState.PAUSED
	var changed: bool = gsm.change_state(GameStateManagerService.GameState.PAUSED)
	var passed: bool = (changed == false) and (gsm.current_state == GameStateManagerService.GameState.PAUSED)
	var msg: String = "State changed should be false"
	gsm.free()
	return {"name": "GameStateManager: Invalid Transition Guard", "passed": passed, "message": msg}
