class_name SkeletonArcher
extends EnemyBase

var arrow_scene: PackedScene = preload("res://scenes/items/arrow_projectile.tscn")

func _ready() -> void:
	enemy_name = "Skeleton Archer"
	max_health = 35.0
	move_speed = 65.0
	attack_damage = 12.0
	attack_range = 220.0
	attack_cooldown_sec = 2.0
	detection_radius = 350.0
	armor = 0.0
	xp_reward = 25
	science_point_reward = 4
	
	loot_table = [
		{ "id": &"arrow", "min": 2, "max": 6, "chance": 1.0 },
		{ "id": &"stick", "min": 1, "max": 3, "chance": 0.7 }
	]
	
	super._ready()

func _perform_attack() -> void:
	_attack_timer = attack_cooldown_sec
	
	if not is_instance_valid(target_entity):
		return
	
	# Fire arrow projectile at target entity
	if is_inside_tree() and get_parent():
		var arrow: Projectile = arrow_scene.instantiate() as Projectile
		arrow.global_position = global_position
		arrow.direction = (target_entity.global_position - global_position).normalized()
		arrow.damage = attack_damage
		arrow.hit_team = 1 # Enemy team
		arrow.source_entity = self
		get_parent().add_child(arrow)
		
		# Animate bow release
		if sprite:
			var t: Tween = create_tween()
			t.tween_property(sprite, "scale", _base_scale * Vector2(1.2, 0.8), 0.08)
			t.tween_property(sprite, "scale", _base_scale, 0.1)
