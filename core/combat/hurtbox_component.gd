class_name HurtboxComponent
extends Area2D

signal hit_received(amount: float, is_critical: bool, attacker: Node2D)
signal invulnerability_started()
signal invulnerability_ended()

@export var hurt_team: int = 1 # 0=Player, 1=Enemy, 2=Neutral
@export var invulnerability_duration: float = 0.25

var is_invulnerable: bool = false
var _invuln_timer: float = 0.0

func _ready() -> void:
	collision_layer = 32 # Physics Layer 6 (Hurtboxes)
	collision_mask = 16  # Physics Layer 5 (Hitboxes)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_invulnerable:
		_invuln_timer -= delta
		if _invuln_timer <= 0.0:
			is_invulnerable = false
			invulnerability_ended.emit()

func _on_area_entered(area: Area2D) -> void:
	if is_invulnerable:
		return
	
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area as HitboxComponent
		# Don't hit allies on the same team
		if hitbox.hit_team == hurt_team:
			return
		
		var effective_dmg: float = hitbox.get_effective_damage()
		var attacker: Node2D = hitbox.source_entity
		
		if invulnerability_duration > 0.0:
			is_invulnerable = true
			_invuln_timer = invulnerability_duration
			invulnerability_started.emit()
		
		hitbox.hit_landed.emit(get_parent(), effective_dmg)
		hit_received.emit(effective_dmg, hitbox.is_critical, attacker)
