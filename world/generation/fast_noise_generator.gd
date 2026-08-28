class_name FastNoiseGenerator
extends RefCounted

var world_seed: int = 1337

var _elevation_noise: FastNoiseLite = FastNoiseLite.new()
var _moisture_noise: FastNoiseLite = FastNoiseLite.new()

func _init(seed_val: int = 1337) -> void:
	world_seed = seed_val
	_setup_noise()

func _setup_noise() -> void:
	_elevation_noise.seed = world_seed
	_elevation_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_elevation_noise.frequency = 0.005
	_elevation_noise.fractal_octaves = 3
	
	_moisture_noise.seed = world_seed + 9999
	_moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_moisture_noise.frequency = 0.004
	_moisture_noise.fractal_octaves = 2

func get_elevation(x: float, y: float) -> float:
	return _elevation_noise.get_noise_2d(x, y)

func get_moisture(x: float, y: float) -> float:
	return _moisture_noise.get_noise_2d(x, y)

func get_biome_type_at(x: float, y: float) -> BiomeDefinition.BiomeType:
	var elev: float = get_elevation(x, y)
	var moist: float = get_moisture(x, y)
	
	if elev > 0.35 and moist < 0.1:
		return BiomeDefinition.BiomeType.TUNDRA_SNOW
	elif moist < -0.3:
		return BiomeDefinition.BiomeType.DESERT
	elif moist > 0.3 and elev < 0.0:
		return BiomeDefinition.BiomeType.SWAMP
	elif elev > 0.6:
		return BiomeDefinition.BiomeType.VOLCANIC
	else:
		return BiomeDefinition.BiomeType.FOREST
