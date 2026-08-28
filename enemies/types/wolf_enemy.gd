class_name WolfEnemy
extends EnemyBase

func _ready() -> void:
	enemy_name = "Dire Wolf"
	max_health = 40.0
	move_speed = 115.0
	attack_damage = 14.0
	attack_range = 36.0
	attack_cooldown_sec = 0.9
	detection_radius = 320.0
	armor = 0.0
	xp_reward = 20
	science_point_reward = 3
	
	loot_table = [
		{ "id": &"raw_meat", "min": 1, "max": 2, "chance": 1.0 },
		{ "id": &"fiber", "min": 2, "max": 4, "chance": 0.9 }
	]
	
	super._ready()
