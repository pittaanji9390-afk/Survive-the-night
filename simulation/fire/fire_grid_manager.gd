class_name FireGridManager
extends Node

signal fire_ignited(cell: Vector2i)
signal fire_extinguished(cell: Vector2i)
signal cell_burned_to_ash(cell: Vector2i)

class FireCell:
	var temperature: float = 20.0 # Ambient Celsius
	var fuel: float = 100.0
	var is_burning: bool = false
	var flammability: float = 0.5 # 0.0 (Stone) to 1.0 (Dry Leaves)

var grid: Dictionary = {} # Vector2i -> FireCell

func _ready() -> void:
	ServiceLocator.register_service(&"FireGridManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"FireGridManager")

func register_cell(coord: Vector2i, flammability: float = 0.5, fuel: float = 100.0) -> void:
	var cell: FireCell = FireCell.new()
	cell.flammability = flammability
	cell.fuel = fuel
	grid[coord] = cell

func ignite_cell(coord: Vector2i) -> bool:
	if grid.has(coord):
		var cell: FireCell = grid[coord]
		if cell.flammability > 0.0 and not cell.is_burning and cell.fuel > 0.0:
			cell.is_burning = true
			cell.temperature = 350.0 # Fire burning temp
			fire_ignited.emit(coord)
			return true
	return false

func update_fire_step(delta: float) -> void:
	var burning_coords: Array[Vector2i] = []
	for coord in grid:
		if grid[coord].is_burning:
			burning_coords.append(coord)
	
	for coord in burning_coords:
		var cell: FireCell = grid[coord]
		cell.fuel = maxf(0.0, cell.fuel - 15.0 * delta)
		
		# Heat adjacent neighbors
		var neighbors: Array[Vector2i] = [
			coord + Vector2i.UP,
			coord + Vector2i.DOWN,
			coord + Vector2i.LEFT,
			coord + Vector2i.RIGHT
		]
		
		for n in neighbors:
			if grid.has(n):
				var n_cell: FireCell = grid[n]
				if not n_cell.is_burning and n_cell.flammability > 0.0 and n_cell.fuel > 0.0:
					n_cell.temperature += 40.0 * n_cell.flammability * delta
					if n_cell.temperature >= 100.0: # Auto-ignition threshold
						ignite_cell(n)
		
		if cell.fuel <= 0.0:
			cell.is_burning = false
			cell.temperature = 40.0
			cell_burned_to_ash.emit(coord)
			fire_extinguished.emit(coord)

func extinguish_cell(coord: Vector2i) -> void:
	if grid.has(coord):
		var cell: FireCell = grid[coord]
		cell.is_burning = false
		cell.temperature = 20.0
		fire_extinguished.emit(coord)
