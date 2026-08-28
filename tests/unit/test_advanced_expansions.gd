class_name TestAdvancedExpansions
extends RefCounted

const NetworkManagerClass = preload("res://net/network_manager.gd")
const PlayerNetworkSyncClass = preload("res://net/synchronizer/player_network_sync.gd")
const GuardianDatabaseClass = preload("res://bosses/guardians/guardian_database.gd")
const RocketManagerClass = preload("res://space/rocket_manager.gd")
const MapEditorManagerClass = preload("res://editor/map_editor_manager.gd")

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_network_sync_snapshot())
	results.append(_test_guardian_database_count())
	results.append(_test_rocket_construction_and_launch())
	results.append(_test_map_editor_export_import())
	return results

func _test_network_sync_snapshot() -> Dictionary:
	var packed: Dictionary = PlayerNetworkSyncClass.pack_snapshot(Vector2(120, 240), Vector2(50, -10), 85.0, Vector2.RIGHT)
	var unpacked: Dictionary = PlayerNetworkSyncClass.unpack_snapshot(packed)
	
	var passed: bool = (unpacked["position"] == Vector2(120, 240)) and (unpacked["health"] == 85.0)
	return {"name": "Multiplayer: Snapshot Packing & Interpolation Deserialization", "passed": passed, "message": "Packed and unpacked position & health matching"}

func _test_guardian_database_count() -> Dictionary:
	var total_guardians: int = GuardianDatabaseClass.count()
	var dev: Dictionary = GuardianDatabaseClass.get_guardian(&"eclipse_devourer")
	
	var passed: bool = (total_guardians == 10) and (dev["hp"] == 2000.0)
	return {"name": "Guardians: 10 Legendary Bosses Registry", "passed": passed, "message": "Found 10 guardians, Omega Devourer HP: 2000"}

func _test_rocket_construction_and_launch() -> Dictionary:
	var rocket = RocketManagerClass.new()
	rocket._ready()
	
	rocket.contribute_materials(100.0)
	var can_launch: bool = rocket.launch_rocket()
	var mined_starmetal: int = rocket.mine_orbital_asteroid(2) # 15 * 2 = 30
	
	var passed: bool = can_launch and (mined_starmetal == 30) and (rocket.starmetal_inventory == 30)
	rocket.free()
	return {"name": "Space: Rocket Assembly, Liftoff & Asteroid Mining", "passed": passed, "message": "Rocket launched and mined 30 Starmetal"}

func _test_map_editor_export_import() -> Dictionary:
	var editor = MapEditorManagerClass.new()
	editor._ready()
	
	editor.place_tile(Vector2i(5, 5), 2)
	editor.add_enemy_spawn(Vector2(50, 50), &"zombie")
	
	var exported: Dictionary = editor.export_map_dict()
	
	var imported_editor = MapEditorManagerClass.new()
	var import_ok: bool = imported_editor.import_map_dict(exported)
	
	var passed: bool = import_ok and (imported_editor.custom_tiles[Vector2i(5, 5)] == 2) and (imported_editor.enemy_spawns.size() == 1)
	editor.free()
	imported_editor.free()
	return {"name": "Editor: Custom Level Editor Serialization Roundtrip", "passed": passed, "message": "Tiles and Spawns exported and imported"}
