class_name PlayerStats
extends Node

signal health_changed(current: float, max_health: float)
signal stamina_changed(current: float, max_stamina: float)
signal hunger_changed(current: float, max_hunger: float)
signal temperature_changed(current: float, target_temp: float)
signal player_exhausted()
signal player_died()

var health: StatAttribute
var stamina: StatAttribute
var hunger: StatAttribute
var temperature: StatAttribute
var speed: StatAttribute
var attack_power: StatAttribute
var defense: StatAttribute
var carry_capacity: StatAttribute

var stamina_regen_timer: float = 0.0
var is_sprinting: bool = false
var is_exhausted: bool = false

# Hunger decay rate (points per real-time second)
@export var hunger_drain_rate: float = 0.35
@export var ambient_temperature: float = 20.0 # Celsius

func _init() -> void:
	health = StatAttribute.new(&"Health", 100.0)
	stamina = StatAttribute.new(&"Stamina", 100.0)
	hunger = StatAttribute.new(&"Hunger", 100.0)
	temperature = StatAttribute.new(&"Temperature", 37.0, 37.0, -20.0) # Core body temp
	speed = StatAttribute.new(&"Speed", GameConfig.DEFAULT_PLAYER_SPEED)
	attack_power = StatAttribute.new(&"AttackPower", 10.0)
	defense = StatAttribute.new(&"Defense", 0.0)
	carry_capacity = StatAttribute.new(&"CarryCapacity", 50.0)

func _ready() -> void:
	health.value_changed.connect(_on_health_changed)
	health.depleted.connect(_on_health_depleted)
	stamina.value_changed.connect(_on_stamina_changed)
	stamina.depleted.connect(_on_stamina_depleted)
	hunger.value_changed.connect(_on_hunger_changed)

func update_stats(delta: float, is_moving: bool, sprint_requested: bool) -> void:
	_process_stamina(delta, is_moving, sprint_requested)
	_process_hunger(delta)
	_process_temperature(delta)

func _process_stamina(delta: float, is_moving: bool, sprint_requested: bool) -> void:
	if sprint_requested and is_moving and not is_exhausted and stamina.get_current_value() > 0.0:
		is_sprinting = true
		stamina.modify_current(-GameConfig.SPRINT_STAMINA_DRAIN_PER_SEC * delta)
		stamina_regen_timer = GameConfig.STAMINA_REGEN_DELAY
	else:
		is_sprinting = false
		if stamina_regen_timer > 0.0:
			stamina_regen_timer -= delta
		else:
			var regen_bonus: float = 1.0 if not is_moving else 0.5
			stamina.modify_current(GameConfig.STAMINA_REGEN_PER_SEC * regen_bonus * delta)
			if is_exhausted and stamina.get_current_value() >= 25.0:
				is_exhausted = false

func _process_hunger(delta: float) -> void:
	var multiplier: float = 1.5 if is_sprinting else 1.0
	hunger.modify_current(-hunger_drain_rate * multiplier * delta)
	
	# High hunger slowly heals, empty hunger harms
	if hunger.get_current_value() >= 80.0 and health.get_current_value() < health.get_max_value():
		health.modify_current(1.0 * delta)
	elif hunger.get_current_value() <= 0.0:
		apply_damage(2.0 * delta, null, false)

func _process_temperature(delta: float) -> void:
	var target_temp: float = 37.0
	var diff: float = ambient_temperature - 20.0
	target_temp += diff * 0.1
	var cur: float = temperature.get_current_value()
	temperature.set_current(lerpf(cur, target_temp, delta * 0.1))
	temperature_changed.emit(temperature.get_current_value(), target_temp)

func apply_damage(amount: float, source: Node2D = null, trigger_invuln: bool = true) -> float:
	var def: float = defense.get_max_value()
	var effective_damage: float = maxf(1.0, amount - def)
	health.modify_current(-effective_damage)
	EventBus.entity_damaged.emit(get_parent() as Node2D, source, effective_damage, false)
	return effective_damage

func heal(amount: float) -> void:
	health.modify_current(amount)

func feed(amount: float) -> void:
	hunger.modify_current(amount)

func _on_health_changed(cur: float, max_v: float) -> void:
	health_changed.emit(cur, max_v)
	EventBus.player_stat_changed.emit(&"Health", cur, max_v)

func _on_health_depleted() -> void:
	player_died.emit()
	EventBus.player_died.emit()

func _on_stamina_changed(cur: float, max_v: float) -> void:
	stamina_changed.emit(cur, max_v)
	EventBus.player_stat_changed.emit(&"Stamina", cur, max_v)

func _on_stamina_depleted() -> void:
	is_exhausted = true
	is_sprinting = false
	player_exhausted.emit()

func _on_hunger_changed(cur: float, max_v: float) -> void:
	hunger_changed.emit(cur, max_v)
	EventBus.player_stat_changed.emit(&"Hunger", cur, max_v)
