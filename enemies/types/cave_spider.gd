class_name CaveSpider
extends EnemyBase

func _ready() -> void:
	enemy_name = "Cave Spider"
	max_health = 45.0
	current_health = max_health
	move_speed = 125.0
	attack_damage = 10.0
	attack_range = 36.0
	attack_cooldown_sec = 0.9
	detection_radius = 280.0
	armor = 0.5
	xp_reward = 30
	science_point_reward = 3
	
	loot_table = [
		{ "id": &"fiber", "min": 2, "max": 4, "chance": 0.8 },
		{ "id": &"spider_fang", "min": 1, "max": 2, "chance": 0.5 }
	]
	super._ready()
