class_name GridPathfinder
extends Node

@export var grid_width: int = 50
@export var grid_height: int = 40
@export var cell_size: int = 32

var _astar: AStar2D = AStar2D.new()
var _solid_points: Dictionary = {} # Vector2i -> bool

func _ready() -> void:
	ServiceLocator.register_service(&"GridPathfinder", self)
	_build_grid()
	
	EventBus.structure_placed.connect(_on_structure_placed)
	EventBus.structure_destroyed.connect(_on_structure_destroyed)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"GridPathfinder")

func _build_grid() -> void:
	_astar.clear()
	var half_w: int = grid_width / 2
	var half_h: int = grid_height / 2
	
	for y in range(-half_h, half_h):
		for x in range(-half_w, half_w):
			var pt_id: int = _get_point_id(x, y)
			var world_pos: Vector2 = Vector2(x * cell_size + cell_size * 0.5, y * cell_size + cell_size * 0.5)
			_astar.add_point(pt_id, world_pos)
	
	# Connect adjacent orthogonal neighbors
	for y in range(-half_h, half_h):
		for x in range(-half_w, half_w):
			var pt_id: int = _get_point_id(x, y)
			if x + 1 < half_w:
				_astar.connect_points(pt_id, _get_point_id(x + 1, y))
			if y + 1 < half_h:
				_astar.connect_points(pt_id, _get_point_id(x, y + 1))

func find_path_world(from_world: Vector2, to_world: Vector2) -> PackedVector2Array:
	var from_id: int = _astar.get_closest_point(from_world)
	var to_id: int = _astar.get_closest_point(to_world)
	
	if from_id == -1 or to_id == -1:
		return PackedVector2Array()
	
	return _astar.get_point_path(from_id, to_id)

func set_point_solid(coords: Vector2i, is_solid: bool) -> void:
	var pt_id: int = _get_point_id(coords.x, coords.y)
	if _astar.has_point(pt_id):
		_astar.set_point_disabled(pt_id, is_solid)
		if is_solid:
			_solid_points[coords] = true
		else:
			_solid_points.erase(coords)

func _get_point_id(x: int, y: int) -> int:
	return (y + 1000) * 2000 + (x + 1000)

func _on_structure_placed(structure_id: StringName, coords: Vector2i) -> void:
	var def: StructureDefinition = StructureDatabase.get_structure(structure_id)
	if def and not def.is_passable:
		set_point_solid(coords, true)

func _on_structure_destroyed(structure: Node2D) -> void:
	if structure and structure.get("grid_coords"):
		var coords: Vector2i = structure.get("grid_coords")
		set_point_solid(coords, false)
