class_name TestWorldGeneration
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_noise_determinism())
	results.append(_test_biome_classification())
	results.append(_test_chunk_coordinate_math())
	return results

func _test_noise_determinism() -> Dictionary:
	var gen_a: FastNoiseGenerator = FastNoiseGenerator.new(12345)
	var gen_b: FastNoiseGenerator = FastNoiseGenerator.new(12345)
	
	var val_a: float = gen_a.get_elevation(100.0, 200.0)
	var val_b: float = gen_b.get_elevation(100.0, 200.0)
	
	var passed: bool = is_equal_approx(val_a, val_b)
	return {"name": "WorldGen: Noise Determinism", "passed": passed, "message": "Elevation values match: %f == %f" % [val_a, val_b]}

func _test_biome_classification() -> Dictionary:
	var gen: FastNoiseGenerator = FastNoiseGenerator.new(12345)
	var b_type: BiomeDefinition.BiomeType = gen.get_biome_type_at(0.0, 0.0)
	var passed: bool = b_type in [BiomeDefinition.BiomeType.FOREST, BiomeDefinition.BiomeType.DESERT, BiomeDefinition.BiomeType.TUNDRA_SNOW, BiomeDefinition.BiomeType.SWAMP, BiomeDefinition.BiomeType.VOLCANIC]
	return {"name": "WorldGen: Biome Classification", "passed": passed, "message": "Evaluated valid biome: %d" % b_type}

func _test_chunk_coordinate_math() -> Dictionary:
	var mgr: ChunkManager = ChunkManager.new()
	mgr.chunk_size_tiles = 16
	mgr.tile_size = 32 # 512px per chunk
	
	var c_pos_a: Vector2i = mgr.world_to_chunk_coords(Vector2(200, 300)) # (0, 0)
	var c_pos_b: Vector2i = mgr.world_to_chunk_coords(Vector2(600, -100)) # (1, -1)
	
	var passed: bool = (c_pos_a == Vector2i(0, 0)) and (c_pos_b == Vector2i(1, -1))
	mgr.free()
	return {"name": "WorldGen: World To Chunk Coordinates", "passed": passed, "message": "A: %v, B: %v" % [c_pos_a, c_pos_b]}
