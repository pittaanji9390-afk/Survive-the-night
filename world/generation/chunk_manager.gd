class_name ChunkManager
extends Node2D

@export var chunk_size_tiles: int = 16
@export var tile_size: int = 32
@export var chunk_load_radius: int = 1

var loaded_chunks: Dictionary = {} # Vector2i -> WorldChunk
var _noise_generator: FastNoiseGenerator = FastNoiseGenerator.new(4242)
var _player: Node2D = null
var _last_player_chunk: Vector2i = Vector2i(99999, 99999)

func _ready() -> void:
	ServiceLocator.register_service(&"ChunkManager", self)
	_update_loaded_chunks(true)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"ChunkManager")

func _process(_delta: float) -> void:
	if not _player:
		_player = ServiceLocator.get_service(&"Player") as Node2D
		if not _player:
			return
	
	var current_chunk: Vector2i = world_to_chunk_coords(_player.global_position)
	if current_chunk != _last_player_chunk:
		_last_player_chunk = current_chunk
		_update_loaded_chunks(false)

func world_to_chunk_coords(world_pos: Vector2) -> Vector2i:
	var chunk_px: float = float(chunk_size_tiles * tile_size)
	return Vector2i(int(floor(world_pos.x / chunk_px)), int(floor(world_pos.y / chunk_px)))

func _update_loaded_chunks(force: bool) -> void:
	var center: Vector2i = _last_player_chunk if not force else Vector2i.ZERO
	var needed_coords: Dictionary = {}
	
	for dy in range(-chunk_load_radius, chunk_load_radius + 1):
		for dx in range(-chunk_load_radius, chunk_load_radius + 1):
			var c_pos: Vector2i = center + Vector2i(dx, dy)
			needed_coords[c_pos] = true
			if not loaded_chunks.has(c_pos):
				_load_chunk(c_pos)
	
	# Unload distant chunks
	for c_pos in loaded_chunks.keys():
		if not needed_coords.has(c_pos):
			_unload_chunk(c_pos)

func _load_chunk(coords: Vector2i) -> void:
	var chunk: WorldChunk = WorldChunk.new()
	chunk.chunk_size_tiles = chunk_size_tiles
	chunk.tile_size = tile_size
	chunk.setup_chunk(coords, _noise_generator)
	add_child(chunk)
	loaded_chunks[coords] = chunk
	GameLogger.info("ChunkManager", "Loaded chunk at (%d, %d)" % [coords.x, coords.y])

func _unload_chunk(coords: Vector2i) -> void:
	if loaded_chunks.has(coords):
		var chunk: WorldChunk = loaded_chunks[coords]
		if is_instance_valid(chunk):
			chunk.queue_free()
		loaded_chunks.erase(coords)
		GameLogger.info("ChunkManager", "Unloaded distant chunk at (%d, %d)" % [coords.x, coords.y])
