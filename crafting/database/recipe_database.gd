class_name RecipeDatabase
extends RefCounted

static var _recipes: Dictionary = {}
static var _initialized: bool = false

static func get_recipe(id: StringName) -> CraftingRecipe:
	_ensure_initialized()
	if _recipes.has(id):
		return _recipes[id]
	GameLogger.warn("RecipeDatabase", "Recipe '%s' not found in database!" % id)
	return null

static func has_recipe(id: StringName) -> bool:
	_ensure_initialized()
	return _recipes.has(id)

static func get_all_recipes() -> Array[CraftingRecipe]:
	_ensure_initialized()
	var list: Array[CraftingRecipe] = []
	for k in _recipes:
		list.append(_recipes[k])
	return list

static func get_recipes_by_category(category: ItemDefinition.Category) -> Array[CraftingRecipe]:
	_ensure_initialized()
	var list: Array[CraftingRecipe] = []
	for k in _recipes:
		var rec: CraftingRecipe = _recipes[k]
		if rec.category == category:
			list.append(rec)
	return list

static func get_recipes_for_station(station: CraftingRecipe.StationType) -> Array[CraftingRecipe]:
	_ensure_initialized()
	var list: Array[CraftingRecipe] = []
	for k in _recipes:
		var rec: CraftingRecipe = _recipes[k]
		if rec.station_required == station or rec.station_required == CraftingRecipe.StationType.HAND:
			list.append(rec)
	return list

static func register_recipe(recipe: CraftingRecipe) -> void:
	if recipe and recipe.recipe_id != &"":
		_recipes[recipe.recipe_id] = recipe

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_populate_default_recipes()

static func _populate_default_recipes() -> void:
	# ==========================================
	# 1. BASIC HANDCRAFTING & MATERIAL REFINING
	# ==========================================
	_add_recipe(&"craft_wooden_plank", "Wooden Planks", "Cut raw logs into sturdy building planks.",
		ItemDefinition.Category.MATERIAL, CraftingRecipe.StationType.HAND, 1.0, &"", true, 2,
		[{ "id": &"wood", "count": 1 }],
		[{ "id": &"wooden_plank", "count": 4, "chance": 1.0 }])

	_add_recipe(&"craft_sticks", "Wooden Sticks", "Carve planks or wood into durable sticks.",
		ItemDefinition.Category.MATERIAL, CraftingRecipe.StationType.HAND, 0.8, &"", true, 1,
		[{ "id": &"wood", "count": 1 }],
		[{ "id": &"stick", "count": 4, "chance": 1.0 }])

	_add_recipe(&"craft_rope", "Braided Rope", "Braid plant fibers into tough binding cord.",
		ItemDefinition.Category.MATERIAL, CraftingRecipe.StationType.HAND, 1.2, &"", true, 2,
		[{ "id": &"fiber", "count": 4 }],
		[{ "id": &"rope", "count": 1, "chance": 1.0 }])

	# ==========================================
	# 2. PRIMITIVE TOOLS & WEAPONS (HAND/WORKBENCH)
	# ==========================================
	_add_recipe(&"craft_stone_axe", "Stone Axe", "Essential timber felling tool.",
		ItemDefinition.Category.TOOL, CraftingRecipe.StationType.HAND, 2.0, &"", true, 5,
		[{ "id": &"stone", "count": 3 }, { "id": &"stick", "count": 2 }, { "id": &"rope", "count": 1 }],
		[{ "id": &"stone_axe", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_stone_pickaxe", "Stone Pickaxe", "Quarry stone and shallow minerals.",
		ItemDefinition.Category.TOOL, CraftingRecipe.StationType.HAND, 2.0, &"", true, 5,
		[{ "id": &"stone", "count": 3 }, { "id": &"stick", "count": 2 }, { "id": &"rope", "count": 1 }],
		[{ "id": &"stone_pickaxe", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_wooden_sword", "Wooden Club", "Basic blunt defensive weapon.",
		ItemDefinition.Category.WEAPON, CraftingRecipe.StationType.HAND, 1.5, &"", true, 4,
		[{ "id": &"wood", "count": 4 }, { "id": &"rope", "count": 1 }],
		[{ "id": &"wooden_sword", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_stone_sword", "Stone Blade", "Knapped serrated stone hunting blade.",
		ItemDefinition.Category.WEAPON, CraftingRecipe.StationType.WORKBENCH, 2.5, &"tech_stone_age", true, 8,
		[{ "id": &"stone", "count": 4 }, { "id": &"flint", "count": 2 }, { "id": &"stick", "count": 2 }, { "id": &"rope", "count": 1 }],
		[{ "id": &"stone_sword", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_hunting_bow", "Hunting Bow", "Flexible ranged curved weapon.",
		ItemDefinition.Category.WEAPON, CraftingRecipe.StationType.WORKBENCH, 3.0, &"tech_archery", true, 10,
		[{ "id": &"wood", "count": 5 }, { "id": &"rope", "count": 3 }],
		[{ "id": &"hunting_bow", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_arrows", "Flint Arrows", "Quiver of 10 razor flint arrows.",
		ItemDefinition.Category.RESOURCE, CraftingRecipe.StationType.HAND, 1.5, &"tech_archery", true, 3,
		[{ "id": &"stick", "count": 3 }, { "id": &"flint", "count": 2 }, { "id": &"fiber", "count": 2 }],
		[{ "id": &"arrow", "count": 10, "chance": 1.0 }])

	# ==========================================
	# 3. ADVANCED FORGED TOOLS & WEAPONS (ANVIL)
	# ==========================================
	_add_recipe(&"craft_iron_axe", "Iron Axe", "Master crafted high-tier woodcutting axe.",
		ItemDefinition.Category.TOOL, CraftingRecipe.StationType.WORKBENCH, 4.0, &"tech_ironworking", false, 15,
		[{ "id": &"iron_ingot", "count": 3 }, { "id": &"stick", "count": 2 }, { "id": &"rope", "count": 1 }],
		[{ "id": &"iron_axe", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_iron_pickaxe", "Iron Pickaxe", "Heavy mining tool for deep ores.",
		ItemDefinition.Category.TOOL, CraftingRecipe.StationType.WORKBENCH, 4.0, &"tech_ironworking", false, 15,
		[{ "id": &"iron_ingot", "count": 3 }, { "id": &"stick", "count": 2 }, { "id": &"rope", "count": 1 }],
		[{ "id": &"iron_pickaxe", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_iron_sword", "Iron Broadsword", "Deadly tempered broadsword.",
		ItemDefinition.Category.WEAPON, CraftingRecipe.StationType.WORKBENCH, 4.5, &"tech_ironworking", false, 20,
		[{ "id": &"iron_ingot", "count": 4 }, { "id": &"stick", "count": 2 }, { "id": &"rope", "count": 2 }],
		[{ "id": &"iron_sword", "count": 1, "chance": 1.0 }])

	# ==========================================
	# 4. ARMOR & SURVIVAL GEAR
	# ==========================================
	_add_recipe(&"craft_leather_cap", "Leather Cap", "Supple hide cap protecting head.",
		ItemDefinition.Category.ARMOR, CraftingRecipe.StationType.WORKBENCH, 2.5, &"tech_tanning", true, 6,
		[{ "id": &"fiber", "count": 6 }, { "id": &"rope", "count": 2 }],
		[{ "id": &"leather_cap", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_leather_tunic", "Leather Tunic", "Reinforced hide torso protection.",
		ItemDefinition.Category.ARMOR, CraftingRecipe.StationType.WORKBENCH, 3.5, &"tech_tanning", true, 10,
		[{ "id": &"fiber", "count": 12 }, { "id": &"rope", "count": 4 }],
		[{ "id": &"leather_tunic", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_leather_boots", "Leather Boots", "Comfortable boots increasing sprint.",
		ItemDefinition.Category.ARMOR, CraftingRecipe.StationType.WORKBENCH, 2.5, &"tech_tanning", true, 6,
		[{ "id": &"fiber", "count": 8 }, { "id": &"rope", "count": 2 }],
		[{ "id": &"leather_boots", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_iron_chestplate", "Iron Chestplate", "Heavy fortified plate mail.",
		ItemDefinition.Category.ARMOR, CraftingRecipe.StationType.WORKBENCH, 6.0, &"tech_armorsmithing", false, 25,
		[{ "id": &"iron_ingot", "count": 8 }, { "id": &"rope", "count": 4 }],
		[{ "id": &"iron_chestplate", "count": 1, "chance": 1.0 }])

	# ==========================================
	# 5. SMELTING & METALLURGY (FURNACE)
	# ==========================================
	_add_recipe(&"smelt_iron_ingot", "Smelt Iron Ingot", "Refine raw iron ore into pure ingots.",
		ItemDefinition.Category.MATERIAL, CraftingRecipe.StationType.FURNACE, 3.0, &"tech_smelting", false, 8,
		[{ "id": &"iron_ore", "count": 2 }, { "id": &"coal", "count": 1 }],
		[{ "id": &"iron_ingot", "count": 1, "chance": 1.0 }])

	_add_recipe(&"smelt_gold_ingot", "Smelt Gold Ingot", "Refine precious gold mineral.",
		ItemDefinition.Category.MATERIAL, CraftingRecipe.StationType.FURNACE, 4.0, &"tech_metallurgy", false, 15,
		[{ "id": &"gold_ore", "count": 2 }, { "id": &"coal", "count": 1 }],
		[{ "id": &"gold_ingot", "count": 1, "chance": 1.0 }])

	# ==========================================
	# 6. COOKING & MEDICINE (CAMPFIRE/ALCHEMY)
	# ==========================================
	_add_recipe(&"cook_roasted_meat", "Roasted Steak", "Sear raw meat over embers into delicious meal.",
		ItemDefinition.Category.FOOD, CraftingRecipe.StationType.CAMPFIRE, 2.0, &"", true, 4,
		[{ "id": &"raw_meat", "count": 1 }, { "id": &"wood", "count": 1 }],
		[{ "id": &"cooked_meat", "count": 1, "chance": 1.0 }])

	_add_recipe(&"craft_medicinal_salve", "Healing Salve", "Crush herbs and berries into restorative balm.",
		ItemDefinition.Category.CONSUMABLE, CraftingRecipe.StationType.HAND, 1.5, &"", true, 5,
		[{ "id": &"healing_herb", "count": 2 }, { "id": &"berries", "count": 2 }],
		[{ "id": &"healing_herb", "count": 1, "chance": 1.0 }])

static func _add_recipe(id: StringName, name: String, desc: String, cat: ItemDefinition.Category, station: CraftingRecipe.StationType, craft_time: float, tech: StringName, default_unlocked: bool, xp: int, ing: Array[Dictionary], res: Array[Dictionary]) -> CraftingRecipe:
	var rec: CraftingRecipe = CraftingRecipe.new()
	rec.recipe_id = id
	rec.display_name = name
	rec.description = desc
	rec.category = cat
	rec.station_required = station
	rec.craft_time_sec = craft_time
	rec.tech_required = tech
	rec.unlocked_by_default = default_unlocked
	rec.experience_reward = xp
	rec.ingredients = ing
	rec.results = res
	register_recipe(rec)
	return rec
