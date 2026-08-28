class_name BroodmotherBoss
extends EnemyBase

signal broodmother_phase_changed(new_phase: int)
signal broodmother_health_updated(cur: float, max_val: float)

enum BroodPhase {
	PHASE_1_WEB_SPINNER,
	PHASE_2_BROOD_CALLER,
	PHASE_3_ACID_FRENZY
}

var current_brood_phase: BroodPhase = BroodPhase.PHASE_1_WEB_SPINNER
var spider_scene: PackedScene = preload("res://scenes/enemies/cave_spider.tscn") if ResourceLoader.exists("res://scenes/enemies/cave_spider.tscn") else null

func _ready() -> void:
	enemy_name = "BROODMOTHER ARACHNA"
	max_health = 650.0
	current_health = max_health
	move_speed = 90.0
	attack_damage = 26.0
	attack_range = 52.0
	attack_cooldown_sec = 1.3
	detection_radius = 500.0
	armor = 5.0
	xp_reward = 350
	science_point_reward = 35
	
	loot_table = [
		{ "id": &"ruby", "min": 2, "max": 4, "chance": 1.0 },
		{ "id": &"sapphire", "min": 2, "max": 4, "chance": 1.0 },
		{ "id": &"mythril_ingot", "min": 3, "max": 6, "chance": 1.0 },
		{ "id": &"spider_fang", "min": 2, "max": 5, "chance": 1.0 }
	]
	
	super._ready()
	EventBus.notification_posted.emit("BOSS LAIR", "The Broodmother stirs in the deep cavern!", "danger")
	EventBus.screen_shake_requested.emit(0.4)

func take_damage(amount: float, attacker: Node2D = null, is_critical: bool = false) -> float:
	var taken: float = super.take_damage(amount, attacker, is_critical)
	broodmother_health_updated.emit(current_health, max_health)
	_check_phase_transition()
	return taken

func _check_phase_transition() -> void:
	var health_ratio: float = current_health / max_health
	
	if health_ratio <= 0.33 and current_brood_phase != BroodPhase.PHASE_3_ACID_FRENZY:
		current_brood_phase = BroodPhase.PHASE_3_ACID_FRENZY
		move_speed = 135.0
		attack_damage = 34.0
		attack_cooldown_sec = 0.75
		broodmother_phase_changed.emit(3)
		EventBus.notification_posted.emit("BROODMOTHER ENRAGED", "Acidic bile coats the cavern walls!", "danger")
		EventBus.screen_shake_requested.emit(0.35)
	elif health_ratio <= 0.66 and current_brood_phase == BroodPhase.PHASE_1_WEB_SPINNER:
		current_brood_phase = BroodPhase.PHASE_2_BROOD_CALLER
		move_speed = 110.0
		attack_damage = 28.0
		attack_cooldown_sec = 1.0
		broodmother_phase_changed.emit(2)
		EventBus.notification_posted.emit("BROODMOTHER HATCHING", "Broodlings emerge from their cocoons!", "warn")
		_spawn_hatchlings()

func _spawn_hatchlings() -> void:
	if not spider_scene or not is_inside_tree() or not get_parent():
		return
	
	for i in range(3):
		var sp: EnemyBase = spider_scene.instantiate() as EnemyBase
		if sp:
			sp.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
			get_parent().add_child(sp)

func _perform_attack() -> void:
	_attack_timer = attack_cooldown_sec
	
	if is_instance_valid(target_entity) and global_position.distance_to(target_entity.global_position) <= attack_range + 16.0:
		var p_stats: PlayerStats = target_entity.get_node_or_null("PlayerStats") as PlayerStats
		if p_stats:
			p_stats.apply_damage(attack_damage, self, true)
			EventBus.screen_shake_requested.emit(0.25)
