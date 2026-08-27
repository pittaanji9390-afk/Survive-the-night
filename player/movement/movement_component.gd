class_name MovementComponent
extends Node

@export var acceleration: float = 1200.0
@export var friction: float = 1000.0

var facing_direction: Vector2 = Vector2.DOWN
var last_movement_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false

func compute_velocity(current_velocity: Vector2, input_dir: Vector2, target_speed: float, delta: float) -> Vector2:
	if input_dir.length_squared() > 0.001:
		is_moving = true
		facing_direction = MathUtils.direction_to_cardinal_8(input_dir)
		last_movement_direction = input_dir.normalized()
		var target_vel: Vector2 = input_dir.normalized() * target_speed
		return current_velocity.move_toward(target_vel, acceleration * delta)
	else:
		is_moving = false
		return current_velocity.move_toward(Vector2.ZERO, friction * delta)

func get_cardinal_facing_name() -> String:
	var dir: Vector2 = facing_direction
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"
