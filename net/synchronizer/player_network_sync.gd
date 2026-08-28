class_name PlayerNetworkSync
extends RefCounted

static func pack_snapshot(pos: Vector2, vel: Vector2, hp: float, facing: Vector2) -> Dictionary:
	return {
		"x": pos.x,
		"y": pos.y,
		"vx": vel.x,
		"vy": vel.y,
		"hp": hp,
		"fx": facing.x,
		"fy": facing.y
	}

static func unpack_snapshot(data: Dictionary) -> Dictionary:
	return {
		"position": Vector2(data.get("x", 0.0), data.get("y", 0.0)),
		"velocity": Vector2(data.get("vx", 0.0), data.get("vy", 0.0)),
		"health": float(data.get("hp", 100.0)),
		"facing": Vector2(data.get("fx", 0.0), data.get("fy", 1.0))
	}
