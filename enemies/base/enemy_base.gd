class_name EnemyBase
extends CharacterBody2D

signal enemy_died(enemy: Node2D, killer: Node2D)
signal enemy_damaged(amount: float, cur_hp: float, max_hp: float)

enum AIState {
	IDLE,
	CHASE,
	ATTACK,
	HURT,
	DEAD
}

@export var enemy_name: String = "Monster"
@export var max_health: float = 60.0
@export var move_speed: float = 75.0
@export var attack_damage: float = 12.0
@export var attack_range: float = 36.0
@export var attack_cooldown_sec: float = 1.2
@export var detection_radius: float = 240.0
@export var armor: float = 1.0
@export var xp_reward: int = 15
@export var science_point_reward: int = 2

# Loot table: [{ "id": StringName, "min": int, "max": int, "chance": float }]
@export var loot_table: Array[Dictionary] = []

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var hurtbox: HurtboxComponent = get_node_or_null("HurtboxComponent") as HurtboxComponent
@onready var hitbox: HitboxComponent = get_node_or_null("HitboxComponent") as HitboxComponent

var current_health: float = 60.0
var current_state: AIState = AIState.IDLE
var target_entity: Node2D = null

var _attack_timer: float = 0.0
var _base_scale: Vector2 = Vector2.ONE
var _tween: Tween

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	
	if sprite:
		_base_scale = sprite.scale
	
	if hurtbox:
		hurtbox.hit_received.connect(_on_hit_received)
	
	if hitbox:
		hitbox.damage = attack_damage
		hitbox.hit_team = 1 # Enemy team
		hitbox.source_entity = self

func _physics_process(delta: float) -> void:
	if current_state == AIState.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if _attack_timer > 0.0:
		_attack_timer -= delta
	
	_update_ai(delta)
	move_and_slide()

func _update_ai(delta: float) -> void:
	if not is_instance_valid(target_entity):
		target_entity = ServiceLocator.get_service(&"Player") as Node2D
	
	if not is_instance_valid(target_entity):
		velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
		current_state = AIState.IDLE
		return
	
	var dist: float = global_position.distance_to(target_entity.global_position)
	
	if dist <= detection_radius:
		if dist <= attack_range:
			current_state = AIState.ATTACK
			velocity = Vector2.ZERO
			if _attack_timer <= 0.0:
				_perform_attack()
		else:
			current_state = AIState.CHASE
			var dir: Vector2 = (target_entity.global_position - global_position).normalized()
			velocity = dir * move_speed
			if sprite and abs(dir.x) > 0.1:
				sprite.flip_h = dir.x < 0.0
	else:
		current_state = AIState.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, 200.0 * delta)

func _perform_attack() -> void:
	_attack_timer = attack_cooldown_sec
	
	# Wind-up telegraph animation
	if sprite:
		var t: Tween = create_tween()
		t.tween_property(sprite, "scale", _base_scale * Vector2(1.25, 0.8), 0.1)
		t.tween_property(sprite, "scale", _base_scale, 0.12)
	
	# Direct melee hit on player if in range
	if is_instance_valid(target_entity) and target_entity.has_method("get_node_or_null"):
		var p_stats: PlayerStats = target_entity.get_node_or_null("PlayerStats") as PlayerStats
		if p_stats and global_position.distance_to(target_entity.global_position) <= attack_range + 10.0:
			p_stats.apply_damage(attack_damage, self, true)
			EventBus.screen_shake_requested.emit(0.2)

func take_damage(amount: float, attacker: Node2D = null, is_critical: bool = false) -> float:
	var effective: float = maxf(1.0, amount - armor)
	current_health = maxf(0.0, current_health - effective)
	
	_play_hurt_effects()
	enemy_damaged.emit(effective, current_health, max_health)
	
	# Spawn floating combat text
	if is_inside_tree():
		DamagePipeline.spawn_damage_number(get_parent(), global_position, effective, is_critical)
	
	if current_health <= 0.0:
		die(attacker)
	
	return effective

func _on_hit_received(amount: float, is_crit: bool, attacker: Node2D) -> void:
	take_damage(amount, attacker, is_crit)

func _play_hurt_effects() -> void:
	if not sprite:
		return
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	sprite.modulate = Color(2.0, 0.4, 0.4, 1.0)
	_tween.tween_property(sprite, "scale", _base_scale * Vector2(0.85, 1.15), 0.05)
	_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.12)
	_tween.tween_property(sprite, "scale", _base_scale, 0.06)

func die(killer: Node2D = null) -> void:
	current_state = AIState.DEAD
	enemy_died.emit(self, killer)
	EventBus.entity_died.emit(self, killer)
	
	# Reward research science points
	var tech_tree: TechTreeManager = ServiceLocator.get_service(&"TechTree") as TechTreeManager
	if tech_tree and science_point_reward > 0:
		tech_tree.add_research_points(science_point_reward)
	
	_spawn_loot_drops()
	
	if is_inside_tree() and sprite:
		var death_tween: Tween = create_tween()
		death_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.25)
		death_tween.tween_callback(queue_free)
	else:
		queue_free()

func _spawn_loot_drops() -> void:
	var drop_scene: PackedScene = preload("res://scenes/items/item_drop.tscn")
	var parent_node: Node = get_parent()
	if not parent_node or not is_inside_tree():
		return
	
	for drop_info in loot_table:
		var id: StringName = drop_info.get("id", &"")
		var min_c: int = int(drop_info.get("min", 1))
		var max_c: int = int(drop_info.get("max", 1))
		var chance: float = float(drop_info.get("chance", 1.0))
		
		if randf() <= chance:
			var count: int = randi_range(min_c, max_c)
			if count > 0:
				var drop: ItemDrop = drop_scene.instantiate() as ItemDrop
				drop.item_id = id
				drop.quantity = count
				var scatter: Vector2 = Vector2(randf_range(-15.0, 15.0), randf_range(-15.0, 15.0))
				drop.global_position = global_position + scatter
				parent_node.call_deferred("add_child", drop)
