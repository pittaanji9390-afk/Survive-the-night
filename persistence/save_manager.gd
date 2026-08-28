class_name SaveManager
extends Node

signal game_saved(slot_id: int)
signal game_loaded(slot_id: int)

@export var autosave_interval_sec: float = 180.0
@export var is_autosave_enabled: bool = true

var _autosave_timer: float = 0.0

func _ready() -> void:
	ServiceLocator.register_service(&"SaveManager", self)
	_ensure_save_directory()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"SaveManager")

func _process(delta: float) -> void:
	if not is_autosave_enabled or not GameStateManager.is_gameplay_active():
		return
	
	_autosave_timer += delta
	if _autosave_timer >= autosave_interval_sec:
		_autosave_timer = 0.0
		save_game(1)
		EventBus.notification_posted.emit("Autosave", "Game progress automatically saved.", "save")

func _ensure_save_directory() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")

func get_save_path(slot_id: int) -> String:
	return "user://saves/save_slot_%d.json" % slot_id

func has_save(slot_id: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot_id))

func save_game(slot_id: int) -> bool:
	_ensure_save_directory()
	var data: Dictionary = _gather_save_data()
	
	var file: FileAccess = FileAccess.open(get_save_path(slot_id), FileAccess.WRITE)
	if not file:
		GameLogger.error("SaveManager", "Failed to open save file for writing: %s" % get_save_path(slot_id))
		return false
	
	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
	game_saved.emit(slot_id)
	GameLogger.info("SaveManager", "Successfully saved game to slot %d" % slot_id)
	return true

func load_game(slot_id: int) -> bool:
	var path: String = get_save_path(slot_id)
	if not FileAccess.file_exists(path):
		GameLogger.warn("SaveManager", "No save file found at %s" % path)
		return false
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return false
	
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_err: Error = json.parse(json_string)
	if parse_err != OK:
		GameLogger.error("SaveManager", "Failed to parse save JSON: %s" % json.get_error_message())
		return false
	
	var data: Dictionary = json.data as Dictionary
	_apply_save_data(data)
	
	game_loaded.emit(slot_id)
	EventBus.notification_posted.emit("Game Loaded", "Successfully restored slot %d" % slot_id, "save")
	GameLogger.info("SaveManager", "Successfully loaded game from slot %d" % slot_id)
	return true

func _gather_save_data() -> Dictionary:
	var save_dict: Dictionary = {
		"timestamp": Time.get_unix_time_from_system(),
		"day_number": TimeManager.current_day,
		"day_time": TimeManager.current_hour
	}
	
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player:
		save_dict["player_pos"] = { "x": player.global_position.x, "y": player.global_position.y }
		var inv: InventoryContainer = player.get_node_or_null("InventoryContainer") as InventoryContainer
		if inv:
			save_dict["inventory"] = inv.serialize()
	
	var tech_tree: TechTreeManager = ServiceLocator.get_service(&"TechTree") as TechTreeManager
	if tech_tree:
		save_dict["tech_tree"] = tech_tree.serialize()
	
	var exp_mgr: ExperienceManager = ServiceLocator.get_service(&"ExperienceManager") as ExperienceManager
	if exp_mgr:
		save_dict["progression"] = exp_mgr.serialize()
	
	var skill_mgr: SkillTreeManager = ServiceLocator.get_service(&"SkillTreeManager") as SkillTreeManager
	if skill_mgr:
		save_dict["skills"] = skill_mgr.serialize()
	
	return save_dict

func _apply_save_data(data: Dictionary) -> void:
	if data.has("day_number"):
		TimeManager.current_day = int(data["day_number"])
	if data.has("day_time"):
		TimeManager.set_time(float(data["day_time"]))
	
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player and data.has("player_pos"):
		var pos_dict: Dictionary = data["player_pos"]
		player.global_position = Vector2(float(pos_dict.get("x", 0)), float(pos_dict.get("y", 0)))
		var inv: InventoryContainer = player.get_node_or_null("InventoryContainer") as InventoryContainer
		if inv and data.has("inventory"):
			inv.deserialize(data["inventory"])
	
	var tech_tree: TechTreeManager = ServiceLocator.get_service(&"TechTree") as TechTreeManager
	if tech_tree and data.has("tech_tree"):
		tech_tree.deserialize(data["tech_tree"])
	
	var exp_mgr: ExperienceManager = ServiceLocator.get_service(&"ExperienceManager") as ExperienceManager
	if exp_mgr and data.has("progression"):
		exp_mgr.deserialize(data["progression"])
	
	var skill_mgr: SkillTreeManager = ServiceLocator.get_service(&"SkillTreeManager") as SkillTreeManager
	if skill_mgr and data.has("skills"):
		skill_mgr.deserialize(data["skills"])
