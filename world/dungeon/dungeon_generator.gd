class_name DungeonGenerator
extends RefCounted

enum TileType {
	FLOOR = 0,
	WALL = 1,
	ENTRANCE_LADDER = 2,
	EXIT_LADDER = 3,
	ORE_RUBY = 4,
	ORE_SAPPHIRE = 5,
	ORE_MYTHRIL = 6,
	HAZARD_STALACTITE = 7
}

var width: int = 40
var height: int = 40
var random_fill_percent: int = 44
var seed_val: int = 777

var grid: Array = [] # 2D Array of TileType

func _init(w: int = 40, h: int = 40, s: int = 777) -> void:
	width = w
	height = h
	seed_val = s

func generate_dungeon() -> Array:
	_init_grid()
	_random_fill()
	
	for i in range(4):
		_smooth_grid()
	
	_ensure_boundary_walls()
	_connect_and_filter_regions()
	_scatter_ores_and_hazards()
	return grid

func _init_grid() -> void:
	grid.clear()
	for y in range(height):
		var row: Array = []
		for x in range(width):
			row.append(TileType.WALL)
		grid.append(row)

func _random_fill() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_val
	
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			if rng.randi_range(0, 100) < random_fill_percent:
				grid[y][x] = TileType.WALL
			else:
				grid[y][x] = TileType.FLOOR

func _smooth_grid() -> void:
	var new_grid: Array = []
	for y in range(height):
		var row: Array = []
		for x in range(width):
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				row.append(TileType.WALL)
				continue
			
			var wall_count: int = _get_surrounding_wall_count(x, y)
			if wall_count > 4:
				row.append(TileType.WALL)
			elif wall_count < 4:
				row.append(TileType.FLOOR)
			else:
				row.append(grid[y][x])
		new_grid.append(row)
	grid = new_grid

func _get_surrounding_wall_count(grid_x: int, grid_y: int) -> int:
	var count: int = 0
	for ny in range(grid_y - 1, grid_y + 2):
		for nx in range(grid_x - 1, grid_x + 2):
			if nx >= 0 and nx < width and ny >= 0 and ny < height:
				if nx != grid_x or ny != grid_y:
					if grid[ny][nx] == TileType.WALL:
						count += 1
			else:
				count += 1
	return count

func _ensure_boundary_walls() -> void:
	for x in range(width):
		grid[0][x] = TileType.WALL
		grid[height - 1][x] = TileType.WALL
	for y in range(height):
		grid[y][0] = TileType.WALL
		grid[y][width - 1] = TileType.WALL

func _connect_and_filter_regions() -> void:
	var regions: Array = _get_regions(TileType.FLOOR)
	if regions.is_empty():
		return
	
	# Find biggest cavern region
	var biggest_region: Array = regions[0]
	for r in regions:
		if r.size() > biggest_region.size():
			biggest_region = r
	
	# Fill all smaller disconnected pockets with walls
	for r in regions:
		if r != biggest_region:
			for tile in r:
				grid[tile.y][tile.x] = TileType.WALL
	
	# Place entrance and exit ladder at distant points in the biggest cavern
	if biggest_region.size() > 2:
		var entrance: Vector2i = biggest_region[0]
		var exit: Vector2i = biggest_region[biggest_region.size() - 1]
		grid[entrance.y][entrance.x] = TileType.ENTRANCE_LADDER
		grid[exit.y][exit.x] = TileType.EXIT_LADDER

func _get_regions(tile_type: int) -> Array:
	var regions: Array = []
	var visited: Array = []
	for y in range(height):
		var v_row: Array = []
		for x in range(width):
			v_row.append(false)
		visited.append(v_row)
	
	for y in range(height):
		for x in range(width):
			if not visited[y][x] and grid[y][x] == tile_type:
				var new_region: Array[Vector2i] = _flood_fill_region(x, y, visited, tile_type)
				regions.append(new_region)
	return regions

func _flood_fill_region(start_x: int, start_y: int, visited: Array, tile_type: int) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var queue: Array[Vector2i] = [Vector2i(start_x, start_y)]
	visited[start_y][start_x] = true
	
	while not queue.is_empty():
		var tile: Vector2i = queue.pop_front()
		tiles.append(tile)
		
		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = tile.x + dir.x
			var ny: int = tile.y + dir.y
			if nx >= 0 and nx < width and ny >= 0 and ny < height:
				if not visited[ny][nx] and grid[ny][nx] == tile_type:
					visited[ny][nx] = true
					queue.append(Vector2i(nx, ny))
	return tiles

func _scatter_ores_and_hazards() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_val + 54321
	
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			if grid[y][x] == TileType.FLOOR:
				var roll: int = rng.randi_range(0, 100)
				if roll < 3:
					grid[y][x] = TileType.ORE_RUBY
				elif roll < 6:
					grid[y][x] = TileType.ORE_SAPPHIRE
				elif roll < 9:
					grid[y][x] = TileType.ORE_MYTHRIL
				elif roll < 12:
					grid[y][x] = TileType.HAZARD_STALACTITE
