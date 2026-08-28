class_name PlayerController
extends CharacterBody2D

signal interaction_target_changed(target: Node)

@onready var movement_component: MovementComponent = $MovementComponent
@onready var stats: PlayerStats = $PlayerStats
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var inventory: InventoryContainer = $InventoryContainer
@onready var hotbar: HotbarManager = $HotbarManager
@onready var equipment: EquipmentInventory = $EquipmentInventory
@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_label: Label = $InteractionPrompt

var current_interactable: Node = null
var _nearby_interactables: Array[Node] = []
var _attack_cooldown: float = 0.0

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
	
	_grant_starter_items()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"Player")

func _physics_process(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta
	
	if not GameStateManager.is_gameplay_active():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	_handle_input_and_movement(delta)
	_handle_actions()
	_handle_interaction()
	_update_visuals()

func _grant_starter_items() -> void:
	if inventory:
		# Starter gear for testing gathering immediately
		inventory.add_item(&"stone_axe", 1)
		inventory.add_item(&"stone_pickaxe", 1)
		inventory.add_item(&"berries", 10)
		inventory.add_item(&"wood", 5)

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
	
	var base_speed: float = stats.speed.get_max_value()
	var current_target_speed: float = base_speed
	if state_machine.is_state(PlayerStateMachine.PlayerState.SPRINT):
		current_target_speed *= GameConfig.SPRINT_SPEED_MULTIPLIER
	
	velocity = movement_component.compute_velocity(velocity, input_vector, current_target_speed, delta)
	move_and_slide()

func _handle_actions() -> void:
	if InputManager.is_attacking() and _attack_cooldown <= 0.0:
		_perform_gather_or_attack()

func _perform_gather_or_attack() -> void:
	var active_item: ItemDefinition = hotbar.get_active_item() if hotbar else null
	
	var t_type: ItemDefinition.ToolType = active_item.tool_type if active_item else ItemDefinition.ToolType.NONE
	var t_tier: int = active_item.tool_tier if active_item else 0
	var damage: float = active_item.base_damage if active_item else 5.0
	var stam_cost: float = active_item.stamina_cost_per_use if active_item else 4.0
	var attack_speed: float = active_item.attack_speed if active_item else 1.0
	
	if stats.stamina.get_current_value() < stam_cost:
		GameLogger.info("Player", "Too exhausted to swing!")
		return
	
	# Deduct stamina for swinging
	stats.stamina.modify_current(-stam_cost)
	stats.stamina_regen_timer = 1.0
	_attack_cooldown = 1.0 / maxf(0.5, attack_speed)
	
	# Swing effect & weapon animation feedback
	_animate_swing()
	
	# Check for resource node or interactable target in front of player
	var target_node: ResourceNode = _find_target_resource_node()
	if target_node:
		var dealt: float = target_node.hit(damage, t_type, t_tier, self)
		GameLogger.info("Player", "Hit %s for %.1f damage." % [target_node.node_name, dealt])
	else:
		# Air swing screen trauma
		EventBus.screen_shake_requested.emit(0.05)

func _animate_swing() -> void:
	if not sprite:
		return
	var tween: Tween = create_tween()
	var base_rot: float = sprite.rotation
	tween.tween_property(sprite, "rotation", base_rot + 0.35, 0.08)
	tween.tween_property(sprite, "rotation", base_rot, 0.1)

func _find_target_resource_node() -> ResourceNode:
	var facing: Vector2 = movement_component.facing_direction
	var attack_reach: float = 48.0
	var hit_center: Vector2 = global_position + facing * (attack_reach * 0.5)
	
	var closest_node: ResourceNode = null
	var min_dist_sq: float = (attack_reach * attack_reach)
	
	for item in _nearby_interactables:
		if item is ResourceNode and not item.is_depleted:
			var d_sq: float = hit_center.distance_squared_to(item.global_position)
			if d_sq < min_dist_sq:
				min_dist_sq = d_sq
				closest_node = item
	
	return closest_node

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
