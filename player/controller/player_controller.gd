class_name PlayerController
extends CharacterBody2D

signal interaction_target_changed(target: Node)

@onready var movement_component: MovementComponent = $MovementComponent
@onready var stats: PlayerStats = $PlayerStats
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_label: Label = $InteractionPrompt

var current_interactable: Node = null
var _nearby_interactables: Array[Node] = []

func _ready() -> void:
	ServiceLocator.register_service(&"Player", self)
	EventBus.player_spawned.emit(self)
	
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)
	
	stats.player_died.connect(_on_player_died)
	
	if interaction_label:
		interaction_label.visible = false

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"Player")

func _physics_process(delta: float) -> void:
	if not GameStateManager.is_gameplay_active():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	_handle_input_and_movement(delta)
	_handle_interaction()
	_update_visuals()

func _handle_input_and_movement(delta: float) -> void:
	if not state_machine.can_move():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_vector: Vector2 = InputManager.get_movement_vector()
	var sprint_requested: bool = InputManager.is_sprinting()
	var is_moving: bool = input_vector.length_squared() > 0.001
	
	stats.update_stats(delta, is_moving, sprint_requested)
	
	# Determine state
	if not is_moving:
		state_machine.transition_to(PlayerStateMachine.PlayerState.IDLE)
	elif stats.is_sprinting:
		state_machine.transition_to(PlayerStateMachine.PlayerState.SPRINT)
	else:
		state_machine.transition_to(PlayerStateMachine.PlayerState.MOVE)
	
	# Calculate target speed
	var base_speed: float = stats.speed.get_max_value()
	var current_target_speed: float = base_speed
	if state_machine.is_state(PlayerStateMachine.PlayerState.SPRINT):
		current_target_speed *= GameConfig.SPRINT_SPEED_MULTIPLIER
	
	velocity = movement_component.compute_velocity(velocity, input_vector, current_target_speed, delta)
	move_and_slide()

func _handle_interaction() -> void:
	_update_best_interactable()
	
	if InputManager.is_interacting() and current_interactable != null:
		if current_interactable.has_method("interact"):
			current_interactable.interact(self)
			EventBus.player_interacted_with.emit(current_interactable)

func _update_visuals() -> void:
	if not sprite:
		return
	
	var facing: Vector2 = movement_component.facing_direction
	if abs(facing.x) > 0.1:
		sprite.flip_h = facing.x < 0.0

func _update_best_interactable() -> void:
	var closest: Node = null
	var min_dist_sq: float = INF
	
	# Clean invalid references
	for i in range(_nearby_interactables.size() - 1, -1, -1):
		var item: Node = _nearby_interactables[i]
		if not is_instance_valid(item):
			_nearby_interactables.remove_at(i)
			continue
		
		var target_pos: Vector2 = (item as Node2D).global_position if item is Node2D else global_position
		var dist_sq: float = global_position.distance_squared_to(target_pos)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest = item
	
	if current_interactable != closest:
		current_interactable = closest
		interaction_target_changed.emit(current_interactable)
		if interaction_label:
			if current_interactable:
				var prompt_text: String = "[E] Interact"
				if current_interactable.has_method("get_interaction_prompt"):
					prompt_text = current_interactable.get_interaction_prompt()
				interaction_label.text = prompt_text
				interaction_label.visible = true
			else:
				interaction_label.visible = false

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable") and not _nearby_interactables.has(area):
		_nearby_interactables.append(area)

func _on_interaction_area_exited(area: Area2D) -> void:
	_nearby_interactables.erase(area)

func _on_interaction_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable") and not _nearby_interactables.has(body):
		_nearby_interactables.append(body)

func _on_interaction_body_exited(body: Node2D) -> void:
	_nearby_interactables.erase(body)

func _on_player_died() -> void:
	state_machine.transition_to(PlayerStateMachine.PlayerState.DEAD)
	GameLogger.info("Player", "Player died.")
