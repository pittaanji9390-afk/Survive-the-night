class_name PlayerStats
extends Node

signal stat_changed(stat_name: String, current: float, maximum: float)
signal player_died()

@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var max_hunger: float = 100.0
@export var base_speed: float = 120.0

var health: StatAttribute
var stamina: StatAttribute
var hunger: StatAttribute
var speed: StatAttribute

var thirst: ThirstAttribute = ThirstAttribute.new()
var is_sprinting: bool = false
var stamina_regen_timer: float = 0.0
var hunger_drain_rate: float = 0.2

func _ready() -> void:
	health = StatAttribute.new(&"Health", max_health)
	stamina = StatAttribute.new(&"Stamina", max_stamina)
	hunger = StatAttribute.new(&"Hunger", max_hunger)
	speed = StatAttribute.new(&"Speed", base_speed)
	
	health.value_changed.connect(func(c, m): stat_changed.emit("health", c, m))
	stamina.value_changed.connect(func(c, m): stat_changed.emit("stamina", c, m))
	hunger.value_changed.connect(func(c, m): stat_changed.emit("hunger", c, m))
	speed.value_changed.connect(func(c, m): stat_changed.emit("speed", c, m))
	
	health.depleted.connect(_on_health_depleted)

func update_stats(delta: float, is_moving: bool, sprint_requested: bool) -> void:
	is_sprinting = sprint_requested and is_moving and stamina.get_current_value() > 0.0
	
	if is_sprinting:
		stamina.modify_current(-GameConfig.STAMINA_DRAIN_SPRINT * delta)
		stamina_regen_timer = GameConfig.STAMINA_REGEN_DELAY
	else:
		if stamina_regen_timer > 0.0:
			stamina_regen_timer -= delta
		else:
			stamina.modify_current(GameConfig.STAMINA_REGEN_RATE * delta)
	
	# Hunger drain
	var hunger_multiplier: float = 1.8 if is_sprinting else (1.2 if is_moving else 1.0)
	hunger.modify_current(-hunger_drain_rate * hunger_multiplier * delta)
	
	# Thirst drain
	thirst.update_thirst(delta, is_sprinting, 20.0, self)
	
	# Starvation damage
	if hunger.get_current_value() <= 0.0:
		apply_damage(GameConfig.STARVATION_DAMAGE_RATE * delta, null, false)
	
	# Passive healing when hunger > 80%
	if hunger.get_current_value() > 80.0 and health.get_current_value() < health.get_max_value():
		heal(GameConfig.PASSIVE_HEAL_RATE * delta)

func apply_damage(amount: float, attacker: Node = null, shake_camera: bool = true) -> void:
	if health.get_current_value() <= 0.0:
		return
	
	health.modify_current(-amount)
	EventBus.player_damaged.emit(amount, attacker)
	
	if shake_camera:
		EventBus.screen_shake_requested.emit(0.25)

func heal(amount: float) -> void:
	health.modify_current(amount)
	EventBus.player_healed.emit(amount)

func feed(amount: float) -> void:
	hunger.modify_current(amount)
	EventBus.player_fed.emit(amount)

func drink(amount: float) -> void:
	thirst.drink(amount)

func _on_health_depleted() -> void:
	player_died.emit()
	EventBus.player_died.emit()
