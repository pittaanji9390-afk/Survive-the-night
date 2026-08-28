class_name ItemDatabase
extends RefCounted

static var _items: Dictionary = {}
static var _initialized: bool = false

static func get_item(id: StringName) -> ItemDefinition:
	_ensure_initialized()
	if _items.has(id):
		return _items[id]
	GameLogger.warn("ItemDatabase", "Item '%s' not found in database!" % id)
	return null

static func has_item(id: StringName) -> bool:
	_ensure_initialized()
	return _items.has(id)

static func get_all_items() -> Array[ItemDefinition]:
	_ensure_initialized()
	var list: Array[ItemDefinition] = []
	for k in _items:
		list.append(_items[k])
	return list

static func get_items_by_category(category: ItemDefinition.Category) -> Array[ItemDefinition]:
	_ensure_initialized()
	var list: Array[ItemDefinition] = []
	for k in _items:
		var item: ItemDefinition = _items[k]
		if item.category == category:
			list.append(item)
	return list

static func register_item(item: ItemDefinition) -> void:
	if item and item.id != &"":
		_items[item.id] = item

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_populate_default_database()

static func _populate_default_database() -> void:
	# 1. Basic Resources
	_create_resource(&"wood", "Wood", "Sturdy timber chopped from trees. Essential for crafting and construction.", 99, 0.4, 2)
	_create_resource(&"stick", "Stick", "Small wooden branches gathered from foliage or broken branches.", 99, 0.1, 1)
	_create_resource(&"stone", "Stone", "Dense raw rock quarried from boulders. Used in primitive tools and stonework.", 99, 0.8, 2)
	_create_resource(&"flint", "Flint", "Sharp mineral flake useful for making spark sources and bladed stone heads.", 99, 0.3, 3)
	_create_resource(&"coal", "Coal", "Combustible carbon lump used as efficient furnace fuel and torch making.", 99, 0.5, 4)
	_create_resource(&"iron_ore", "Iron Ore", "Raw unrefined iron mineral. Can be smelted into durable iron ingots.", 99, 1.2, 6)
	_create_resource(&"gold_ore", "Gold Ore", "Precious golden ore. Prized for valuable craftsmanship and arcane trinkets.", 99, 1.5, 15)
	_create_resource(&"fiber", "Plant Fiber", "Flexible dried natural plant threads used for making rope and cloth.", 99, 0.1, 1)
	_create_resource(&"clay", "Clay", "Malleable earth mineral suitable for ceramics and masonry bricks.", 99, 0.6, 2)
	_create_resource(&"copper_ore", "Copper Ore", "Malleable reddish metal ore found in shallow rocky crags.", 99, 1.0, 5)

	# 2. Food & Consumables
	_create_food(&"berries", "Forest Berries", "Sweet wild berries gathered from forest bushes. Restores modest hunger.", 50, 0.1, 2, 0.0, 5.0, 15.0)
	_create_food(&"apple", "Crisp Apple", "A juicy ripe red apple picked from wild trees. Restores health and hunger.", 50, 0.2, 4, 8.0, 10.0, 20.0)
	_create_food(&"healing_herb", "Healing Herb", "Potent medicinal leaves that soothe wounds and rapidly regenerate health.", 30, 0.1, 8, 25.0, 0.0, 0.0)
	_create_food(&"raw_meat", "Raw Meat", "Uncooked animal meat. Edible in emergencies, but risky when raw.", 30, 0.5, 3, -5.0, 0.0, 20.0)
	_create_food(&"cooked_meat", "Roasted Steak", "Delicious seasoned roasted meat cooked over fire. Excellent nourishment.", 30, 0.5, 12, 15.0, 20.0, 50.0)

	# 3. Gathering Tools
	_create_tool(&"stone_axe", "Stone Axe", "A primitive handaxe bound with rope. Effective at felling trees.", ItemDefinition.ToolType.AXE, 2, 12.0, 1.1, 100, 15)
	_create_tool(&"iron_axe", "Iron Axe", "A finely forged iron axe capable of cutting the densest hard timber swiftly.", ItemDefinition.ToolType.AXE, 3, 22.0, 1.3, 250, 45)
	_create_tool(&"stone_pickaxe", "Stone Pickaxe", "A sturdy chisel pick for breaking rocks and harvesting raw stone.", ItemDefinition.ToolType.PICKAXE, 2, 10.0, 1.0, 100, 15)
	_create_tool(&"iron_pickaxe", "Iron Pickaxe", "Heavy iron pickaxe designed to extract tough metal ores cleanly.", ItemDefinition.ToolType.PICKAXE, 3, 20.0, 1.2, 250, 45)

	# 4. Weapons
	_create_weapon(&"wooden_sword", "Wooden Club", "A carved blunt wooden club for fending off nocturnal beasts.", 14.0, 1.2, 45.0, 80, 10)
	_create_weapon(&"stone_sword", "Stone Blade", "A knapped stone dagger with serrated edge. Moderate damage.", 20.0, 1.4, 48.0, 120, 20)
	_create_weapon(&"iron_sword", "Iron Broadsword", "A sharp balanced steel blade delivering deadly sweeping slashes.", 32.0, 1.5, 52.0, 250, 60)
	_create_weapon(&"hunting_bow", "Hunting Bow", "A flexible wooden curved bow capable of launching arrows at distance.", 25.0, 0.9, 250.0, 150, 40)
	_create_resource(&"arrow", "Flint Arrow", "Feathered wooden projectile tipped with razor flint.", 99, 0.05, 1)

	# 5. Armor & Equipment
	_create_armor(&"leather_cap", "Leather Cap", "Supple hardened leather headwear offering basic thermal protection.", ItemDefinition.EquipmentSlotType.HEAD, 2.0, 0.0, 5.0, 100, 20)
	_create_armor(&"leather_tunic", "Leather Tunic", "Reinforced hide armor protecting the torso from claws and fangs.", ItemDefinition.EquipmentSlotType.CHEST, 5.0, 0.0, 15.0, 150, 35)
	_create_armor(&"leather_boots", "Leather Boots", "Sturdy exploration boots providing enhanced sprinting endurance.", ItemDefinition.EquipmentSlotType.FEET, 2.0, 10.0, 5.0, 120, 25)
	_create_armor(&"iron_chestplate", "Iron Chestplate", "Heavy polished metal plate armor granting substantial defense.", ItemDefinition.EquipmentSlotType.CHEST, 14.0, -5.0, 30.0, 300, 100)

	# 6. Crafted Materials
	_create_resource(&"wooden_plank", "Wooden Plank", "Processed lumber planed flat for building floors, walls, and chests.", 99, 0.3, 4)
	_create_resource(&"iron_ingot", "Iron Ingot", "Pure refined iron bar cast from a smelting furnace.", 99, 1.0, 15)
	_create_resource(&"gold_ingot", "Gold Ingot", "Brilliant pure gold bar of exceptional value and ductility.", 99, 1.2, 40)
	_create_resource(&"rope", "Braided Rope", "Strong braided plant fiber cordage used in construction and bindings.", 99, 0.2, 5)

static func _create_resource(id: StringName, name: String, desc: String, max_stk: int, wt: float, val: int) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = id
	item.name = name
	item.description = desc
	item.category = ItemDefinition.Category.RESOURCE
	item.rarity = ItemDefinition.Rarity.COMMON
	item.max_stack = max_stk
	item.weight = wt
	item.value = val
	register_item(item)
	return item

static func _create_food(id: StringName, name: String, desc: String, max_stk: int, wt: float, val: int, hp: float, stam: float, hung: float) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = id
	item.name = name
	item.description = desc
	item.category = ItemDefinition.Category.FOOD
	item.rarity = ItemDefinition.Rarity.COMMON
	item.max_stack = max_stk
	item.weight = wt
	item.value = val
	item.health_restore = hp
	item.stamina_restore = stam
	item.hunger_restore = hung
	register_item(item)
	return item

static func _create_tool(id: StringName, name: String, desc: String, t_type: ItemDefinition.ToolType, tier: int, dmg: float, spd: float, dur: int, val: int) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = id
	item.name = name
	item.description = desc
	item.category = ItemDefinition.Category.TOOL
	item.rarity = ItemDefinition.Rarity.UNCOMMON if tier > 2 else ItemDefinition.Rarity.COMMON
	item.max_stack = 1
	item.weight = 2.0
	item.value = val
	item.tool_type = t_type
	item.tool_tier = tier
	item.base_damage = dmg
	item.attack_speed = spd
	item.max_durability = dur
	item.equip_slot = ItemDefinition.EquipmentSlotType.MAIN_HAND
	register_item(item)
	return item

static func _create_weapon(id: StringName, name: String, desc: String, dmg: float, spd: float, rng: float, dur: int, val: int) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = id
	item.name = name
	item.description = desc
	item.category = ItemDefinition.Category.WEAPON
	item.rarity = ItemDefinition.Rarity.COMMON
	item.max_stack = 1
	item.weight = 2.5
	item.value = val
	item.tool_type = ItemDefinition.ToolType.SWORD
	item.tool_tier = 1
	item.base_damage = dmg
	item.attack_speed = spd
	item.attack_range = rng
	item.max_durability = dur
	item.equip_slot = ItemDefinition.EquipmentSlotType.MAIN_HAND
	register_item(item)
	return item

static func _create_armor(id: StringName, name: String, desc: String, slot: ItemDefinition.EquipmentSlotType, def: float, spd_mod: float, hp_mod: float, dur: int, val: int) -> ItemDefinition:
	var item: ItemDefinition = ItemDefinition.new()
	item.id = id
	item.name = name
	item.description = desc
	item.category = ItemDefinition.Category.ARMOR
	item.rarity = ItemDefinition.Rarity.COMMON
	item.max_stack = 1
	item.weight = 3.0
	item.value = val
	item.equip_slot = slot
	item.defense_bonus = def
	item.speed_modifier = spd_mod
	item.max_health_bonus = hp_mod
	item.max_durability = dur
	register_item(item)
	return item
