class_name BuildingManager
extends Node2D

@export var tile_size: int = 32
@export var max_build_distance: float = 180.0

var is_building_mode: bool = false
var is_deconstruct_mode: bool = false
var selected_structure_id: StringName = &"wood_wall"

var _preview_sprite: Sprite2D = null
var _placed_structures: Dictionary = {} # Vector2i -> StructureInstance
var _player: Node2D = null
var _inventory: InventoryContainer = null

func _ready() -> void:
	ServiceLocator.register_service(&"BuildingManager", self)
	_setup_preview_sprite()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"BuildingManager")

func _setup_preview_sprite() -> void:
	_preview_sprite = Sprite2D.new()
	_preview_sprite.texture = preload("res://assets/tiles/stone_wall.png")
	_preview_sprite.modulate = Color(0.4, 1.0, 0.4, 0.6)
	_preview_sprite.visible = false
	add_child(_preview_sprite)

func _process(_delta: float) -> void:
	if not is_building_mode and not is_deconstruct_mode:
		if _preview_sprite:
			_preview_sprite.visible = false
		return
	
	_update_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_building"):
		toggle_building_mode()
		return
	
	if not is_building_mode and not is_deconstruct_mode:
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_building_mode:
				_try_place_structure()
			elif is_deconstruct_mode:
				_try_deconstruct_structure()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			exit_modes()

func toggle_building_mode() -> void:
	if is_building_mode:
		exit_modes()
	else:
		is_building_mode = true
		is_deconstruct_mode = false
		_bind_player()
		if _preview_sprite:
			_preview_sprite.visible = true
		GameStateManager.change_state(GameStateManagerService.GameState.BUILDING)
		EventBus.building_mode_toggled.emit(true)
		GameLogger.info("Building", "Entered Building Mode. [Left Click] Place, [Right Click] Cancel")

func exit_modes() -> void:
	is_building_mode = false
	is_deconstruct_mode = false
	if _preview_sprite:
		_preview_sprite.visible = false
	if GameStateManager.is_state(GameStateManagerService.GameState.BUILDING):
		GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	EventBus.building_mode_toggled.emit(false)

func select_structure(id: StringName) -> void:
	selected_structure_id = id
	is_building_mode = true
	is_deconstruct_mode = false
	_bind_player()
	if _preview_sprite:
		_preview_sprite.visible = true
	_update_preview_texture()

func _bind_player() -> void:
	if not _player:
		_player = ServiceLocator.get_service(&"Player") as Node2D
	if _player and not _inventory:
		_inventory = _player.get_node_or_null("InventoryContainer") as InventoryContainer

func _get_mouse_grid_coords() -> Vector2i:
	var mouse_pos: Vector2 = get_global_mouse_position()
	return MathUtils.world_to_tile(mouse_pos, float(tile_size))

func _update_preview() -> void:
	if not _preview_sprite:
		return
	
	var grid_coords: Vector2i = _get_mouse_grid_coords()
	var world_pos: Vector2 = MathUtils.tile_to_world(grid_coords, float(tile_size)) + Vector2(tile_size * 0.5, tile_size * 0.5)
	_preview_sprite.global_position = world_pos
	_preview_sprite.visible = true
	
	_bind_player()
	var can_build: bool = _can_place_at(grid_coords)
	_preview_sprite.modulate = Color(0.4, 1.2, 0.4, 0.65) if can_build else Color(1.4, 0.3, 0.3, 0.65)

func _can_place_at(coords: Vector2i) -> bool:
	if not _player or not _inventory:
		return false
	
	# Check distance
	var world_pos: Vector2 = MathUtils.tile_to_world(coords, float(tile_size))
	if _player.global_position.distance_to(world_pos) > max_build_distance:
		return false
	
	# Check tile not already occupied
	if _placed_structures.has(coords):
		var existing: StructureInstance = _placed_structures[coords]
		if is_instance_valid(existing):
			return false
	
	# Check materials
	var def: StructureDefinition = StructureDatabase.get_structure(selected_structure_id)
	if not def or not def.can_build(_inventory):
		return false
	
	return true

func _try_place_structure() -> void:
	var coords: Vector2i = _get_mouse_grid_coords()
	if not _can_place_at(coords):
		EventBus.notification_posted.emit("Building", "Cannot place structure here or missing materials!", "warn")
		return
	
	var def: StructureDefinition = StructureDatabase.get_structure(selected_structure_id)
	def.consume_costs(_inventory)
	
	var instance: StructureInstance = _create_structure_node(def, coords)
	_placed_structures[coords] = instance
	
	var parent_world: Node2D = ServiceLocator.get_service(&"World") as Node2D
	if parent_world:
		parent_world.add_child(instance)
	else:
		get_parent().add_child(instance)
	
	EventBus.structure_placed.emit(selected_structure_id, coords)
	EventBus.screen_shake_requested.emit(0.08)
	GameLogger.info("Building", "Placed %s at grid (%d, %d)" % [def.display_name, coords.x, coords.y])

func _try_deconstruct_structure() -> void:
	var coords: Vector2i = _get_mouse_grid_coords()
	if _placed_structures.has(coords):
		var struct_inst: StructureInstance = _placed_structures[coords]
		if is_instance_valid(struct_inst):
			struct_inst.deconstruct(_inventory)
			_placed_structures.erase(coords)
			EventBus.notification_posted.emit("Building", "Deconstructed structure", "info")

func _create_structure_node(def: StructureDefinition, coords: Vector2i) -> StructureInstance:
	var node: StructureInstance
	match def.structure_type:
		StructureDefinition.StructureType.DOOR:
			node = DoorStructure.new()
		StructureDefinition.StructureType.STORAGE:
			node = ChestStructure.new()
		StructureDefinition.StructureType.DEFENSE_TRAP:
			node = SpikeTrapStructure.new()
		StructureDefinition.StructureType.BED:
			node = BedStructure.new()
		_:
			node = StructureInstance.new()
	
	node.structure_id = def.structure_id
	node.grid_coords = coords
	node.global_position = MathUtils.tile_to_world(coords, float(tile_size)) + Vector2(tile_size * 0.5, tile_size * 0.5)
	
	# Add visual sprite
	var spr: Sprite2D = Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = _get_texture_for_structure(def)
	node.add_child(spr)
	
	# Add physics collision if not passable
	if not def.is_passable:
		node.collision_layer = 6
		node.collision_mask = 0
		var col: CollisionShape2D = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(tile_size, tile_size)
		col.shape = shape
		node.add_child(col)
	
	return node

func _get_texture_for_structure(def: StructureDefinition) -> Texture2D:
	match def.structure_type:
		StructureDefinition.StructureType.WALL:
			return preload("res://assets/tiles/stone_wall.png") if def.material_type == StructureDefinition.MaterialType.STONE else preload("res://assets/tiles/dirt_tile.png")
		StructureDefinition.StructureType.FLOOR:
			return preload("res://assets/tiles/dirt_tile.png")
		StructureDefinition.StructureType.DOOR:
			return preload("res://assets/sprites/workbench.png")
		StructureDefinition.StructureType.STORAGE:
			return preload("res://assets/sprites/workbench.png")
		StructureDefinition.StructureType.LIGHT:
			return preload("res://assets/sprites/campfire.png")
		_:
			return preload("res://assets/tiles/stone_wall.png")

func _update_preview_texture() -> void:
	if not _preview_sprite:
		return
	var def: StructureDefinition = StructureDatabase.get_structure(selected_structure_id)
	if def:
		_preview_sprite.texture = _get_texture_for_structure(def)
