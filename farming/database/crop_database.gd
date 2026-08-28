class_name CropDatabase
extends RefCounted

static var _crops: Dictionary = {}
static var _initialized: bool = false

static func get_crop(id: StringName) -> CropDefinition:
	_ensure_initialized()
	if _crops.has(id):
		return _crops[id]
	GameLogger.warn("CropDatabase", "Crop '%s' not found in database!" % id)
	return null

static func get_crop_by_seed(seed_id: StringName) -> CropDefinition:
	_ensure_initialized()
	for k in _crops:
		var c: CropDefinition = _crops[k]
		if c.seed_item_id == seed_id:
			return c
	return null

static func get_all_crops() -> Array[CropDefinition]:
	_ensure_initialized()
	var list: Array[CropDefinition] = []
	for k in _crops:
		list.append(_crops[k])
	return list

static func register_crop(crop_def: CropDefinition) -> void:
	if crop_def and crop_def.crop_id != &"":
		_crops[crop_def.crop_id] = crop_def

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_populate_default_crops()

static func _populate_default_crops() -> void:
	_add_crop(&"crop_wheat", "Wheat", &"seed_wheat", &"wheat", 2, 4, 3, 6.0, true, 10)
	_add_crop(&"crop_carrots", "Carrots", &"seed_carrot", &"berries", 3, 5, 3, 7.0, true, 12)
	_add_crop(&"crop_healing_herbs", "Healing Herbs", &"seed_herb", &"healing_herb", 2, 3, 2, 8.0, true, 15)

static func _add_crop(id: StringName, name: String, seed_id: StringName, harvest_id: StringName, min_y: int, max_y: int, stages: int, stage_time: float, need_water: bool, xp: int) -> CropDefinition:
	var c: CropDefinition = CropDefinition.new()
	c.crop_id = id
	c.crop_name = name
	c.seed_item_id = seed_id
	c.harvest_item_id = harvest_id
	c.harvest_yield_min = min_y
	c.harvest_yield_max = max_y
	c.growth_stages = stages
	c.growth_time_per_stage_sec = stage_time
	c.water_required = need_water
	c.experience_reward = xp
	register_crop(c)
	return c
