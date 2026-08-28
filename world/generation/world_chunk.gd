class_name WorldChunk
extends Node2D

@export var chunk_coords: Vector2i = Vector2i.ZERO
@export var chunk_size_tiles: int = 16
@export var tile_size: int = 32

var biome_type: BiomeDefinition.BiomeType = BiomeDefinition.BiomeType.FOREST

var _tree_script = preload("res://world/resources/tree_node.gd")
var _rock_script = preload("res://world/resources/rock_node.gd")
var _bush_script = preload("res://world/resources/bush_node.gd")

var _tree_tex = preload("res://assets/sprites/tree.png")
var _rock_tex = preload("res://assets/sprites/rock.png")
var _bush_tex = preload("res://assets/sprites/bush.png")

func setup_chunk(coords: Vector2i, noise_gen: FastNoiseGenerator) -> void:
	chunk_coords = coords
	var world_origin: Vector2 = Vector2(coords.x * chunk_size_tiles * tile_size, coords.y * chunk_size_tiles * tile_size)
	global_position = world_origin
	
	if noise_gen:
		biome_type = noise_gen.get_biome_type_at(coords.x * 100.0, coords.y * 100.0)
	
	_generate_terrain_and_nodes()

func _generate_terrain_and_nodes() -> void:
	# Add background ground rect
	var ground: TextureRect = TextureRect.new()
	ground.size = Vector2(chunk_size_tiles * tile_size, chunk_size_tiles * tile_size)
	ground.texture = preload("res://assets/tiles/grass_tile.png") if biome_type == BiomeDefinition.BiomeType.FOREST else preload("res://assets/tiles/dirt_tile.png")
	ground.stretch_mode = TextureRect.STRETCH_TILE
	add_child(ground)
	
	# Seeded deterministic pseudo-random resource scattering
	var chunk_seed: int = int((chunk_coords.x * 73856093) ^ (chunk_coords.y * 19349663))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = chunk_seed
	
	var num_trees: int = rng.randi_range(3, 7)
	for i in range(num_trees):
		var rx: float = rng.randf_range(24.0, (chunk_size_tiles * tile_size) - 24.0)
		var ry: float = rng.randf_range(24.0, (chunk_size_tiles * tile_size) - 24.0)
		_spawn_node(_tree_script, _tree_tex, Vector2(rx, ry))
	
	var num_rocks: int = rng.randi_range(2, 4)
	for i in range(num_rocks):
		var rx: float = rng.randf_range(24.0, (chunk_size_tiles * tile_size) - 24.0)
		var ry: float = rng.randf_range(24.0, (chunk_size_tiles * tile_size) - 24.0)
		_spawn_node(_rock_script, _rock_tex, Vector2(rx, ry))
	
	var num_bushes: int = rng.randi_range(2, 5)
	for i in range(num_bushes):
		var rx: float = rng.randf_range(24.0, (chunk_size_tiles * tile_size) - 24.0)
		var ry: float = rng.randf_range(24.0, (chunk_size_tiles * tile_size) - 24.0)
		_spawn_node(_bush_script, _bush_tex, Vector2(rx, ry))

func _spawn_node(script_class: GDScript, tex: Texture2D, local_pos: Vector2) -> void:
	var node: StaticBody2D = StaticBody2D.new()
	node.set_script(script_class)
	node.position = local_pos
	node.collision_layer = 6
	node.collision_mask = 0
	node.add_to_group("interactable")
	node.add_to_group("resource_node")
	
	var spr: Sprite2D = Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = tex
	node.add_child(spr)
	
	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 14.0
	col.shape = shape
	node.add_child(col)
	
	add_child(node)
