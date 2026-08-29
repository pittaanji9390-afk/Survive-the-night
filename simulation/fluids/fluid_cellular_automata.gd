class_name FluidCellularAutomata
extends RefCounted

class FluidTile:
	var volume: float = 0.0 # 0.0 to 1.0
	var viscosity: float = 0.8 # Water: 0.8 (fast), Lava: 0.2 (slow)
	var is_solid: bool = false

var grid: Dictionary = {} # Vector2i -> FluidTile
var width: int = 20
var height: int = 20

func _init(w: int = 20, h: int = 20) -> void:
	width = w
	height = h
	for y in height:
		for x in width:
			var t: FluidTile = FluidTile.new()
			grid[Vector2i(x, y)] = t

func add_liquid(pos: Vector2i, amount: float, visc: float = 0.8) -> void:
	if grid.has(pos):
		var t: FluidTile = grid[pos]
		t.volume = minf(1.0, t.volume + amount)
		t.viscosity = visc

func set_solid(pos: Vector2i, solid: bool) -> void:
	if grid.has(pos):
		grid[pos].is_solid = solid
		if solid:
			grid[pos].volume = 0.0

func simulate_step() -> void:
	# Downward gravity flow first, then lateral diffusion
	for y in range(height - 2, -1, -1):
		for x in range(width):
			var current_pos: Vector2i = Vector2i(x, y)
			var cur_tile: FluidTile = grid[current_pos]
			if cur_tile.volume <= 0.0 or cur_tile.is_solid:
				continue
			
			var below_pos: Vector2i = Vector2i(x, y + 1)
			var below_tile: FluidTile = grid[below_pos]
			
			# 1. Flow down
			if not below_tile.is_solid and below_tile.volume < 1.0:
				var space: float = 1.0 - below_tile.volume
				var flow: float = minf(cur_tile.volume, space) * cur_tile.viscosity
				cur_tile.volume -= flow
				below_tile.volume += flow
			
			# 2. Flow sideways (left/right equalization)
			if cur_tile.volume > 0.05:
				var left_pos: Vector2i = Vector2i(x - 1, y)
				var right_pos: Vector2i = Vector2i(x + 1, y)
				
				if grid.has(left_pos) and not grid[left_pos].is_solid and grid[left_pos].volume < cur_tile.volume:
					var diff: float = (cur_tile.volume - grid[left_pos].volume) * 0.5 * cur_tile.viscosity
					cur_tile.volume -= diff
					grid[left_pos].volume += diff
				
				if grid.has(right_pos) and not grid[right_pos].is_solid and grid[right_pos].volume < cur_tile.volume:
					var diff: float = (cur_tile.volume - grid[right_pos].volume) * 0.5 * cur_tile.viscosity
					cur_tile.volume -= diff
					grid[right_pos].volume += diff
