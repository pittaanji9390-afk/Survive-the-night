class_name InputManagerService
extends Node

enum InputContext {
	GAMEPLAY,
	UI,
	BUILDING,
	DIALOGUE,
	CUTSCENE
}

var current_context: InputContext = InputContext.GAMEPLAY
var is_mouse_aim_active: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func get_movement_vector() -> Vector2:
	if current_context != InputContext.GAMEPLAY and current_context != InputContext.BUILDING:
		return Vector2.ZERO
	
	var input_vec: Vector2 = Vector2.ZERO
	input_vec.x = Input.get_axis("move_left", "move_right")
	input_vec.y = Input.get_axis("move_up", "move_down")
	
	if input_vec.length_squared() > 1.0:
		input_vec = input_vec.normalized()
	return input_vec

func is_sprinting() -> bool:
	if current_context != InputContext.GAMEPLAY and current_context != InputContext.BUILDING:
		return false
	return Input.is_action_pressed("sprint")

func is_interacting() -> bool:
	if current_context != InputContext.GAMEPLAY:
		return false
	return Input.is_action_just_pressed("interact")

func is_attacking() -> bool:
	if current_context != InputContext.GAMEPLAY:
		return false
	return Input.is_action_just_pressed("attack")

func is_using_item() -> bool:
	if current_context != InputContext.GAMEPLAY and current_context != InputContext.BUILDING:
		return false
	return Input.is_action_just_pressed("use_item")

func set_context(new_context: InputContext) -> void:
	current_context = new_context
	GameLogger.debug("InputManager", "Context changed to: %d" % new_context)
