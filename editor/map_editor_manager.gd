class_name MapEditorManager
extends Node

signal map_modified()
signal map_saved_to_file(map_name: String)

var custom_tiles: Dictionary = {}
var enemy_spawns: Array[Dictionary] = []
var active_map_name: String = "custom_scenario_1"

func _ready() -> void:
	ServiceLocator.register_service(&"MapEditorManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"MapEditorManager")

func place_tile(coord: Vector2i, tile_id: int) -> void:
	custom_tiles[coord] = tile_id
	map_modified.emit()

func erase_tile(coord: Vector2i) -> void:
	custom_tiles.erase(coord)
	map_modified.emit()

func add_enemy_spawn(pos: Vector2, enemy_type: StringName) -> void:
	enemy_spawns.append({ "pos_x": pos.x, "pos_y": pos.y, "type": String(enemy_type) })
	map_modified.emit()

func export_map_dict() -> Dictionary:
	var tile_array: Array[Dictionary] = []
	for coord in custom_tiles:
		tile_array.append({ "x": coord.x, "y": coord.y, "id": custom_tiles[coord] })
	
	return {
		"map_name": active_map_name,
		"tiles": tile_array,
		"spawns": enemy_spawns
	}

func import_map_dict(data: Dictionary) -> bool:
	if not data.has("map_name") or not data.has("tiles"):
		return false
	
	active_map_name = data["map_name"]
	custom_tiles.clear()
	enemy_spawns.clear()
	
	for t in data["tiles"]:
		var coord = Vector2i(int(t.get("x", 0)), int(t.get("y", 0)))
		custom_tiles[coord] = int(t.get("id", 0))
	
	for s in data.get("spawns", []):
		enemy_spawns.append(s)
	
	map_modified.emit()
	return true
