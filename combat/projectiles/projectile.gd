class_name Projectile
extends Area2D

@export var speed: float = 380.0
@export var damage: float = 20.0
@export var max_range: float = 450.0
@export var hit_team: int = 0 # 0=Player, 1=Enemy

var direction: Vector2 = Vector2.RIGHT
var source_entity: Node2D = null

var _distance_travelled: float = 0.0

func _ready() -> void:
	collision_layer = 128 # Layer 8 (Projectiles)
	collision_mask = 34   # Hurtboxes (32) + World Boundaries (2)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var move_delta: Vector2 = direction * speed * delta
	global_position += move_delta
	_distance_travelled += move_delta.length()
	
	rotation = direction.angle()
	
	if _distance_travelled >= max_range:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area as HurtboxComponent
		if hurtbox.hurt_team != hit_team:
			var is_crit: bool = (randf() < 0.2)
			var final_dmg: float = damage * (1.5 if is_crit else 1.0)
			hurtbox.hit_received.emit(final_dmg, is_crit, source_entity)
			EventBus.screen_shake_requested.emit(0.08)
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body != source_entity and not body.is_in_group("player" if hit_team == 0 else "enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, source_entity)
		queue_free()
