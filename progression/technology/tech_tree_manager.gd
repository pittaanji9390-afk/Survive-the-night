class_name TechTreeManager
extends Node

signal tech_unlocked(tech_id: StringName)
signal research_points_changed(current: int)

var available_research_points: int = 25
var unlocked_techs: Array[StringName] = []

var _tech_registry: Dictionary = {}

func _ready() -> void:
	ServiceLocator.register_service(&"TechTree", self)
	_populate_tech_tree()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"TechTree")

func add_research_points(amount: int) -> void:
	if amount <= 0:
		return
	available_research_points += amount
	research_points_changed.emit(available_research_points)
	GameLogger.info("TechTree", "Gained %d research points (Total: %d)" % [amount, available_research_points])

func is_tech_unlocked(tech_id: StringName) -> bool:
	return unlocked_techs.has(tech_id)

func can_unlock_tech(tech_id: StringName, inventory: InventoryContainer = null) -> bool:
	if is_tech_unlocked(tech_id):
		return false
	
	var node: TechNode = get_tech(tech_id)
	if not node:
		return false
	
	# Check research points
	if available_research_points < node.cost_research_points:
		return false
	
	# Check prerequisites
	for prereq in node.prerequisites:
		if not is_tech_unlocked(prereq):
			return false
	
	# Check material costs if inventory provided
	if inventory:
		for mat in node.material_costs:
			var mat_id: StringName = mat.get("id", &"")
			var count: int = int(mat.get("count", 1))
			if inventory.get_item_count(mat_id) < count:
				return false
	
	return true

func unlock_tech(tech_id: StringName, inventory: InventoryContainer = null) -> bool:
	if not can_unlock_tech(tech_id, inventory):
		return false
	
	var node: TechNode = get_tech(tech_id)
	available_research_points -= node.cost_research_points
	research_points_changed.emit(available_research_points)
	
	# Consume materials
	if inventory:
		for mat in node.material_costs:
			var mat_id: StringName = mat.get("id", &"")
			var count: int = int(mat.get("count", 1))
			inventory.remove_item(mat_id, count)
	
	unlocked_techs.append(tech_id)
	tech_unlocked.emit(tech_id)
	EventBus.notification_posted.emit("Technology Researched", "Unlocked: " + node.title, "tech")
	GameLogger.info("TechTree", "Successfully unlocked technology: %s" % node.title)
	return true

func get_tech(id: StringName) -> TechNode:
	return _tech_registry.get(id, null)

func get_all_techs() -> Array[TechNode]:
	var list: Array[TechNode] = []
	for k in _tech_registry:
		list.append(_tech_registry[k])
	return list

func get_techs_by_era(era: TechNode.Era) -> Array[TechNode]:
	var list: Array[TechNode] = []
	for k in _tech_registry:
		var node: TechNode = _tech_registry[k]
		if node.era == era:
			list.append(node)
	return list

func serialize() -> Dictionary:
	var unlocked_str: Array[String] = []
	for t in unlocked_techs:
		unlocked_str.append(String(t))
	return {
		"research_points": available_research_points,
		"unlocked_techs": unlocked_str
	}

func deserialize(data: Dictionary) -> void:
	available_research_points = int(data.get("research_points", 0))
	unlocked_techs.clear()
	var arr: Array = data.get("unlocked_techs", [])
	for t in arr:
		unlocked_techs.append(StringName(t))
	research_points_changed.emit(available_research_points)

func _populate_tech_tree() -> void:
	# ==========================================
	# ERA 1: PRIMITIVE
	# ==========================================
	_register(&"tech_stone_age", "Stone Age Knapping", "Master knapping sharp flint and serrated stone blades.",
		TechNode.Era.PRIMITIVE, 1, 5, [], [], [&"craft_stone_sword"])

	_register(&"tech_tanning", "Hide Tanning", "Process cured plant fibers and animal hides into wearable leather gear.",
		TechNode.Era.PRIMITIVE, 1, 8, [], [], [&"craft_leather_cap", &"craft_leather_tunic", &"craft_leather_boots"])

	_register(&"tech_archery", "Primitive Archery", "Craft flexible wooden bows and fletched flint arrows for ranged hunting.",
		TechNode.Era.PRIMITIVE, 1, 10, [&"tech_stone_age"], [], [&"craft_hunting_bow", &"craft_arrows"])

	# ==========================================
	# ERA 2: SMELTING & METALLURGY
	# ==========================================
	_register(&"tech_smelting", "Ore Smelting", "Construct high-temperature furnaces to extract pure ingots from crude ores.",
		TechNode.Era.BRONZE, 2, 15, [&"tech_stone_age"], [{ "id": &"stone", "count": 10 }], [&"smelt_iron_ingot"])

	_register(&"tech_ironworking", "Iron Forging", "Forge hardened iron axes, pickaxes, and broadswords with high durability.",
		TechNode.Era.IRON, 3, 20, [&"tech_smelting"], [{ "id": &"iron_ingot", "count": 2 }],
		[&"craft_iron_axe", &"craft_iron_pickaxe", &"craft_iron_sword"])

	_register(&"tech_armorsmithing", "Armorsmithing", "Shape tempered iron plates into heavy protective chest mail.",
		TechNode.Era.IRON, 3, 25, [&"tech_ironworking", &"tech_tanning"], [{ "id": &"iron_ingot", "count": 4 }],
		[&"craft_iron_chestplate"])

	_register(&"tech_metallurgy", "Precious Metallurgy", "Refine rare gold and arcane minerals for advanced masterwork technology.",
		TechNode.Era.ADVANCED, 4, 35, [&"tech_ironworking"], [{ "id": &"gold_ore", "count": 4 }],
		[&"smelt_gold_ingot"])

func _register(id: StringName, title: String, desc: String, era: TechNode.Era, tier: int, cost: int, prereqs: Array[StringName], mats: Array[Dictionary], recipes: Array[StringName]) -> void:
	var node: TechNode = TechNode.new()
	node.tech_id = id
	node.title = title
	node.description = desc
	node.era = era
	node.tier = tier
	node.cost_research_points = cost
	node.prerequisites = prereqs
	node.material_costs = mats
	node.unlocked_recipes = recipes
	_tech_registry[id] = node
