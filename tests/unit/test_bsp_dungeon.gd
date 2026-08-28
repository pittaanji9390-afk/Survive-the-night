class_name TestBSPDungeon
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_bsp_room_generation())
	return results

func _test_bsp_room_generation() -> Dictionary:
	var gen: BSPDungeonGenerator = BSPDungeonGenerator.new(60, 60, 12)
	var rooms: Array[Rect2i] = gen.generate_bsp()
	
	var valid_count: bool = rooms.size() >= 4
	var all_inside_bounds: bool = true
	for r in rooms:
		if r.position.x < 0 or r.position.y < 0 or r.end.x > 60 or r.end.y > 60:
			all_inside_bounds = false
	
	var passed: bool = valid_count and all_inside_bounds
	return {"name": "Labyrinth: BSP Recursive Partitioning Rooms", "passed": passed, "message": "Generated %d structured puzzle chambers" % rooms.size()}
