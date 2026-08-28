class_name AutomatedTurretStructure
extends StructureInstance

@export var fire_range: float = 220.0
@export var fire_rate_sec: float = 1.4
@export var projectile_damage: float = 18.0

var arrow_scene: PackedScene = preload("res://scenes/items/arrow_projectile.tscn")
var _fire_timer: float = 0.0

func _ready() -> void:
	structure_id = &"automated_turret"
	super._ready()

func _physics_process(delta: float) -> void:
	if _fire_timer > 0.0:
		_fire_timer -= delta
	
	if _fire_timer <= 0.0:
		_try_fire_at_target()

func _try_fire_at_target() -> void:
	var target: EnemyBase = _find_closest_enemy()
	if not target:
		return
	
	_fire_timer = fire_rate_sec
	
	if is_inside_tree() and get_parent():
		var arrow: Projectile = arrow_scene.instantiate() as Projectile
		arrow.global_position = global_position
		arrow.direction = (target.global_position - global_position).normalized()
		arrow.damage = projectile_damage
		arrow.hit_team = 0 # Player ally team
		arrow.source_entity = self
		get_parent().add_child(arrow)
		
		# Small recoil tween
		if sprite:
			var t: Tween = create_tween()
			t.tween_property(sprite, "scale", _base_scale * Vector2(0.85, 1.15), 0.06)
			t.tween_property(sprite, "scale", _base_scale, 0.08)

func _find_closest_enemy() -> EnemyBase:
	var closest: EnemyBase = null
	var min_d_sq: float = fire_range * fire_range
	
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e is EnemyBase and e.current_state != EnemyBase.AIState.DEAD:
			var d_sq: float = global_position.distance_squared_to(e.global_position)
			if d_sq < min_d_sq:
				min_d_sq = d_sq
				closest = e
	
	return closest
