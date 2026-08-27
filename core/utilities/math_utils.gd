class_name MathUtils
extends RefCounted

static func snap_to_grid(pos: Vector2, grid_size: float = 32.0) -> Vector2:
	return (pos / grid_size).floor() * grid_size

static func snap_to_grid_center(pos: Vector2, grid_size: float = 32.0) -> Vector2:
	return (pos / grid_size).floor() * grid_size + Vector2(grid_size * 0.5, grid_size * 0.5)

static func world_to_tile(pos: Vector2, grid_size: float = 32.0) -> Vector2i:
	return Vector2i(int(floor(pos.x / grid_size)), int(floor(pos.y / grid_size)))

static func tile_to_world(tile_coords: Vector2i, grid_size: float = 32.0) -> Vector2:
	return Vector2(tile_coords.x * grid_size, tile_coords.y * grid_size)

static func direction_to_cardinal_8(dir: Vector2) -> Vector2:
	if dir.length_squared() < 0.001:
		return Vector2.ZERO
	var angle: float = dir.angle() # [-PI, PI]
	var octant: int = int(round(angle / (PI / 4.0)))
	if octant < 0:
		octant += 8
	octant = octant % 8
	var octants: Array[Vector2] = [
		Vector2.RIGHT,
		Vector2(1, 1).normalized(),
		Vector2.DOWN,
		Vector2(-1, 1).normalized(),
		Vector2.LEFT,
		Vector2(-1, -1).normalized(),
		Vector2.UP,
		Vector2(1, -1).normalized()
	]
	return octants[octant]

static func decay(a: float, b: float, decay_rate: float, dt: float) -> float:
	return b + (a - b) * exp(-decay_rate * dt)

static func decay_vector2(a: Vector2, b: Vector2, decay_rate: float, dt: float) -> Vector2:
	return b + (a - b) * exp(-decay_rate * dt)
