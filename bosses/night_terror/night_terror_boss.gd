class_name NightTerrorBoss
extends EnemyBase

signal boss_phase_changed(new_phase: int)
signal boss_health_updated(cur: float, max_val: float)

enum BossPhase {
	PHASE_1_STALKER,
	PHASE_2_ENRAGED,
	PHASE_3_FRENZY
}

var current_boss_phase: BossPhase = BossPhase.PHASE_1_STALKER
var arrow_scene: PackedScene = preload("res://scenes/items/arrow_projectile.tscn")

func _ready() -> void:
	enemy_name = "THE NIGHT TERROR"
	max_health = 500.0
	current_health = max_health
	move_speed = 85.0
	attack_damage = 22.0
	attack_range = 48.0
	attack_cooldown_sec = 1.4
	detection_radius = 450.0
	armor = 3.0
	xp_reward = 250
	science_point_reward = 25
	
	loot_table = [
		{ "id": &"gold_ingot", "min": 3, "max": 6, "chance": 1.0 },
		{ "id": &"iron_ingot", "min": 5, "max": 10, "chance": 1.0 },
		{ "id": &"cooked_meat", "min": 4, "max": 8, "chance": 1.0 }
	]
	
	super._ready()
	
	EventBus.notification_posted.emit("BOSS ENCOUNTER", "The Night Terror has awakened!", "danger")
	EventBus.screen_shake_requested.emit(0.4)

func take_damage(amount: float, attacker: Node2D = null, is_critical: bool = false) -> float:
	var taken: float = super.take_damage(amount, attacker, is_critical)
	boss_health_updated.emit(current_health, max_health)
	_check_phase_transition()
	return taken

func _check_phase_transition() -> void:
	var health_ratio: float = current_health / max_health
	
	if health_ratio <= 0.33 and current_boss_phase != BossPhase.PHASE_3_FRENZY:
		current_boss_phase = BossPhase.PHASE_3_FRENZY
		move_speed = 130.0
		attack_damage = 30.0
		attack_cooldown_sec = 0.8
		boss_phase_changed.emit(3)
		EventBus.notification_posted.emit("BOSS PHASE 3", "The Night Terror enters a blood frenzy!", "danger")
		EventBus.screen_shake_requested.emit(0.3)
	elif health_ratio <= 0.66 and current_boss_phase == BossPhase.PHASE_1_STALKER:
		current_boss_phase = BossPhase.PHASE_2_ENRAGED
		move_speed = 105.0
		attack_damage = 25.0
		attack_cooldown_sec = 1.0
		boss_phase_changed.emit(2)
		EventBus.notification_posted.emit("BOSS PHASE 2", "The Night Terror enrages!", "warn")
		EventBus.screen_shake_requested.emit(0.2)

func _perform_attack() -> void:
	_attack_timer = attack_cooldown_sec
	
	# Melee slam
	if is_instance_valid(target_entity) and global_position.distance_to(target_entity.global_position) <= attack_range + 16.0:
		var p_stats: PlayerStats = target_entity.get_node_or_null("PlayerStats") as PlayerStats
		if p_stats:
			p_stats.apply_damage(attack_damage, self, true)
			EventBus.screen_shake_requested.emit(0.3)
	
	# Phase 2 & 3: Burst dark projectiles in 5 directions!
	if current_boss_phase != BossPhase.PHASE_1_STALKER and is_inside_tree() and get_parent():
		for i in range(5):
			var angle: float = (i - 2) * (PI / 8.0)
			var base_dir: Vector2 = (target_entity.global_position - global_position).normalized() if is_instance_valid(target_entity) else Vector2.RIGHT
			var fire_dir: Vector2 = base_dir.rotated(angle)
			
			var proj: Projectile = arrow_scene.instantiate() as Projectile
			proj.global_position = global_position
			proj.direction = fire_dir
			proj.damage = 14.0
			proj.hit_team = 1 # Enemy
			proj.source_entity = self
			get_parent().add_child(proj)
