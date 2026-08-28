class_name ZombieEnemy
extends EnemyBase

func _ready() -> void:
	enemy_name = "Nocturnal Zombie"
	max_health = 50.0
	move_speed = 70.0
	attack_damage = 10.0
	attack_range = 32.0
	attack_cooldown_sec = 1.2
	detection_radius = 280.0
	armor = 1.0
	xp_reward = 15
	science_point_reward = 2
	
	loot_table = [
		{ "id": &"fiber", "min": 1, "max": 3, "chance": 0.8 },
		{ "id": &"flint", "min": 1, "max": 2, "chance": 0.4 },
		{ "id": &"raw_meat", "min": 1, "max": 1, "chance": 0.3 }
	]
	
	super._ready()
