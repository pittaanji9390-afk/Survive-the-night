class_name BiomeDefinition
extends Resource

enum BiomeType {
	FOREST,
	DESERT,
	TUNDRA_SNOW,
	SWAMP,
	VOLCANIC
}

@export var biome_id: StringName = &"biome_forest"
@export var biome_name: String = "Temperate Forest"
@export var biome_type: BiomeType = BiomeType.FOREST

@export var ground_tile_texture: Texture2D = null
@export var ambient_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var temperature_offset: float = 0.0

@export var tree_density: float = 0.08
@export var rock_density: float = 0.04
@export var bush_density: float = 0.06

@export var elevation_min: float = -1.0
@export var elevation_max: float = 1.0
@export var moisture_min: float = -1.0
@export var moisture_max: float = 1.0
