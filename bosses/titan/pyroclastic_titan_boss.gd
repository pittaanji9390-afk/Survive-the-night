class_name PyroclasticTitanBoss
extends EnemyBase

signal titan_phase_changed(new_phase: int)
signal titan_health_updated(cur: float, max_val: float)

enum TitanPhase {
	PHASE_1_CRUST,
	PHASE_2_METEOR_STORM,
	PHASE_3_SUPERNOVA
}

var current_titan_phase: TitanPhase = TitanPhase.PHASE_1_CRUST

func _ready() -> void:
	enemy_name = "IGNIS THE PYROCLASTIC TITAN"
	max_health = 850.0
	current_health = max_health
	move_speed = 70.0
	attack_damage = 35.0
	attack_range = 60.0
	attack_cooldown_sec = 1.6
	detection_radius = 550.0
	armor = 6.0
	xp_reward = 500
	science_point_reward = 50
	
	loot_table = [
		{ "id": &"gold_ingot", "min": 5, "max": 10, "chance": 1.0 },
		{ "id": &"ruby", "min": 4, "max": 8, "chance": 1.0 },
		{ "id": &"mythril_ingot", "min": 5, "max": 10, "chance": 1.0 }
	]
	super._ready()
	
	EventBus.notification_posted.emit("WORLD BOSS AWAKENED", "Ignis the Pyroclastic Titan erupts from the earth!", "fire")
	EventBus.screen_shake_requested.emit(0.5)

func take_damage(amount: float, attacker: Node2D = null, is_critical: bool = false) -> float:
	var taken: float = super.take_damage(amount, attacker, is_critical)
	titan_health_updated.emit(current_health, max_health)
	_check_phase_transition()
	return taken

func _check_phase_transition() -> void:
	var health_ratio: float = current_health / max_health
	
	if health_ratio <= 0.33 and current_titan_phase != TitanPhase.PHASE_3_SUPERNOVA:
		current_titan_phase = TitanPhase.PHASE_3_SUPERNOVA
		move_speed = 110.0
		attack_damage = 48.0
		attack_cooldown_sec = 0.9
		titan_phase_changed.emit(3)
		EventBus.notification_posted.emit("TITAN SUPERNOVA", "Ignis radiates apocalyptic heat!", "fire")
		EventBus.screen_shake_requested.emit(0.4)
	elif health_ratio <= 0.66 and current_titan_phase == TitanPhase.PHASE_1_CRUST:
		current_titan_phase = TitanPhase.PHASE_2_METEOR_STORM
		move_speed = 85.0
		attack_damage = 40.0
		attack_cooldown_sec = 1.2
		titan_phase_changed.emit(2)
		EventBus.notification_posted.emit("TITAN METEOR STORM", "Meteors crash from the burning sky!", "warn")
		EventBus.screen_shake_requested.emit(0.3)
