class_name LocomotiveEntity
extends CharacterBody2D

@export var max_steam_speed: float = 220.0
@export var current_speed: float = 0.0
@export var coal_fuel_units: float = 10.0
@export var burn_rate_per_sec: float = 0.1

func _ready() -> void:
	add_to_group("train")
	add_to_group("vehicle")

func update_locomotive(delta: float, throttle_requested: bool) -> void:
	if throttle_requested and coal_fuel_units > 0.0:
		coal_fuel_units = maxf(0.0, coal_fuel_units - burn_rate_per_sec * delta)
		current_speed = minf(max_steam_speed, current_speed + 60.0 * delta)
	else:
		current_speed = maxf(0.0, current_speed - 40.0 * delta) # Natural friction

func add_coal_fuel(amount: float) -> void:
	coal_fuel_units += amount
