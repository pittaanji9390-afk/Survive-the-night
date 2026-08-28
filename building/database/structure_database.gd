class_name StructureDatabase
extends RefCounted

static var _structures: Dictionary = {}
static var _initialized: bool = false

static func get_structure(id: StringName) -> StructureDefinition:
	_ensure_initialized()
	if _structures.has(id):
		return _structures[id]
	GameLogger.warn("StructureDatabase", "Structure '%s' not found in database!" % id)
	return null

static func has_structure(id: StringName) -> bool:
	_ensure_initialized()
	return _structures.has(id)

static func get_all_structures() -> Array[StructureDefinition]:
	_ensure_initialized()
	var list: Array[StructureDefinition] = []
	for k in _structures:
		list.append(_structures[k])
	return list

static func get_structures_by_type(stype: StructureDefinition.StructureType) -> Array[StructureDefinition]:
	_ensure_initialized()
	var list: Array[StructureDefinition] = []
	for k in _structures:
		var s: StructureDefinition = _structures[k]
		if s.structure_type == stype:
			list.append(s)
	return list

static func register_structure(struct_def: StructureDefinition) -> void:
	if struct_def and struct_def.structure_id != &"":
		_structures[struct_def.structure_id] = struct_def

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_populate_default_structures()

static func _populate_default_structures() -> void:
	# ==========================================
	# 1. FLOORS & FOUNDATIONS
	# ==========================================
	_add_struct(&"wood_floor", "Wooden Floor", "Smooth planed timber floorboards.",
		StructureDefinition.StructureType.FLOOR, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 60.0, 0.0, true, false,
		[{ "id": &"wooden_plank", "count": 2 }], &"")

	_add_struct(&"stone_floor", "Stone Paver Floor", "Chiseled interlocking stone tile floor.",
		StructureDefinition.StructureType.FLOOR, StructureDefinition.MaterialType.STONE,
		Vector2i(1, 1), 120.0, 2.0, true, false,
		[{ "id": &"stone", "count": 3 }], &"")

	# ==========================================
	# 2. WALLS & WINDOWS
	# ==========================================
	_add_struct(&"wood_wall", "Wooden Wall", "Solid fortified log barricade wall.",
		StructureDefinition.StructureType.WALL, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 150.0, 1.0, false, false,
		[{ "id": &"wood", "count": 4 }, { "id": &"wooden_plank", "count": 2 }], &"stone_wall_struct")

	_add_struct(&"stone_wall_struct", "Stone Wall", "Heavy bonded stone masonry barrier.",
		StructureDefinition.StructureType.WALL, StructureDefinition.MaterialType.STONE,
		Vector2i(1, 1), 350.0, 5.0, false, false,
		[{ "id": &"stone", "count": 6 }, { "id": &"clay", "count": 2 }], &"iron_wall")

	_add_struct(&"iron_wall", "Reinforced Iron Wall", "Impentrable steel-reinforced wall.",
		StructureDefinition.StructureType.WALL, StructureDefinition.MaterialType.IRON,
		Vector2i(1, 1), 750.0, 12.0, false, false,
		[{ "id": &"iron_ingot", "count": 4 }, { "id": &"stone", "count": 4 }], &"")

	_add_struct(&"wood_window", "Wooden Window Wall", "Wall with arrow slit aperture.",
		StructureDefinition.StructureType.WINDOW, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 110.0, 0.5, false, false,
		[{ "id": &"wood", "count": 3 }, { "id": &"stick", "count": 2 }], &"")

	# ==========================================
	# 3. DOORS & GATES
	# ==========================================
	_add_struct(&"wood_door", "Wooden Door", "Hinged wooden entryway door.",
		StructureDefinition.StructureType.DOOR, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 120.0, 1.0, false, false,
		[{ "id": &"wooden_plank", "count": 4 }, { "id": &"rope", "count": 1 }], &"")

	_add_struct(&"iron_gate", "Reinforced Iron Gate", "Heavy portcullis security gate.",
		StructureDefinition.StructureType.DOOR, StructureDefinition.MaterialType.IRON,
		Vector2i(1, 1), 450.0, 8.0, false, false,
		[{ "id": &"iron_ingot", "count": 4 }, { "id": &"wooden_plank", "count": 2 }], &"")

	# ==========================================
	# 4. STORAGE & CHESTS
	# ==========================================
	_add_struct(&"wood_chest", "Storage Chest", "Wooden chest with 16 storage slots.",
		StructureDefinition.StructureType.STORAGE, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 100.0, 0.0, false, false,
		[{ "id": &"wooden_plank", "count": 6 }, { "id": &"rope", "count": 2 }], &"")

	# ==========================================
	# 5. DEFENSE TRAPS
	# ==========================================
	_add_struct(&"spike_trap", "Wooden Spike Trap", "Concealed sharpened wooden spikes that impale approaching enemies.",
		StructureDefinition.StructureType.DEFENSE_TRAP, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 50.0, 0.0, true, false,
		[{ "id": &"wood", "count": 3 }, { "id": &"stick", "count": 4 }], &"")

	_add_struct(&"barricade_fence", "Barricade Fence", "Pointed palisade fence that slows and damages attackers.",
		StructureDefinition.StructureType.DEFENSE_TRAP, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 120.0, 2.0, false, false,
		[{ "id": &"wood", "count": 4 }, { "id": &"rope", "count": 2 }], &"")

	# ==========================================
	# 6. LIGHTING & UTILITY
	# ==========================================
	_add_struct(&"standing_torch", "Standing Torch", "Mounted pitch torch providing persistent ambient perimeter illumination.",
		StructureDefinition.StructureType.LIGHT, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 40.0, 0.0, false, false,
		[{ "id": &"stick", "count": 2 }, { "id": &"coal", "count": 1 }, { "id": &"fiber", "count": 2 }], &"")

	_add_struct(&"simple_bed", "Comfortable Bed", "Restorative straw and timber cot. Sleep during night to awake at dawn.",
		StructureDefinition.StructureType.BED, StructureDefinition.MaterialType.WOOD,
		Vector2i(1, 1), 80.0, 0.0, false, false,
		[{ "id": &"wooden_plank", "count": 4 }, { "id": &"fiber", "count": 6 }], &"")

static func _add_struct(id: StringName, name: String, desc: String, stype: StructureDefinition.StructureType, mat: StructureDefinition.MaterialType, size: Vector2i, hp: float, arm: float, passable: bool, rot: bool, costs: Array[Dictionary], up_id: StringName) -> StructureDefinition:
	var s: StructureDefinition = StructureDefinition.new()
	s.structure_id = id
	s.display_name = name
	s.description = desc
	s.structure_type = stype
	s.material_type = mat
	s.size_in_tiles = size
	s.max_health = hp
	s.armor = arm
	s.is_passable = passable
	s.can_rotate = rot
	s.construction_costs = costs
	s.upgrade_structure_id = up_id
	register_structure(s)
	return s
