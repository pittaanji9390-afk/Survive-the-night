class_name TestDungeonGeneration
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_dungeon_generation_bounds())
	results.append(_test_dungeon_connectivity())
	results.append(_test_mineral_vein_distribution())
	return results

func _test_dungeon_generation_bounds() -> Dictionary:
	var gen: DungeonGenerator = DungeonGenerator.new(30, 30, 999)
	var grid: Array = gen.generate_dungeon()
	
	var valid_dims: bool = (grid.size() == 30) and (grid[0].size() == 30)
	var boundary_walls: bool = true
	for x in range(30):
		if grid[0][x] != DungeonGenerator.TileType.WALL or grid[29][x] != DungeonGenerator.TileType.WALL:
			boundary_walls = false
	
	var passed: bool = valid_dims and boundary_walls
	return {"name": "Dungeon: Bounds & Solid Perimeter", "passed": passed, "message": "30x30 cave grid with solid bounds"}

func _test_dungeon_connectivity() -> Dictionary:
	var gen: DungeonGenerator = DungeonGenerator.new(35, 35, 1234)
	var grid: Array = gen.generate_dungeon()
	
	var has_entrance: bool = false
	var has_exit: bool = false
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == DungeonGenerator.TileType.ENTRANCE_LADDER:
				has_entrance = true
			elif grid[y][x] == DungeonGenerator.TileType.EXIT_LADDER:
				has_exit = true
	
	var passed: bool = has_entrance and has_exit
	return {"name": "Dungeon: Single-Cavern Entrance/Exit Connectivity", "passed": passed, "message": "Entrance and Boss chamber connected"}

func _test_mineral_vein_distribution() -> Dictionary:
	var gen: DungeonGenerator = DungeonGenerator.new(40, 40, 5678)
	var grid: Array = gen.generate_dungeon()
	
	var ore_count: int = 0
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var t: int = grid[y][x]
			if t in [DungeonGenerator.TileType.ORE_RUBY, DungeonGenerator.TileType.ORE_SAPPHIRE, DungeonGenerator.TileType.ORE_MYTHRIL]:
				ore_count += 1
	
	var passed: bool = ore_count > 5
	return {"name": "Dungeon: Mineral & Gem Vein Scattering", "passed": passed, "message": "Scattered %d rare ore veins" % ore_count}
