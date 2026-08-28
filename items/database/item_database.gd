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
	_populate_default_items()

static func _populate_default_items() -> void:
	# 1. Raw Harvested Resources
	_create_resource(&"wood", "Wood Log", "Freshly chopped timber from trees. Essential for construction and tool handles.", 99, 0.4, 2)
	_create_resource(&"stone", "Raw Stone", "Rough granite quarried from boulders. Used in stone tools and masonry.", 99, 0.8, 2)
	_create_resource(&"iron_ore", "Iron Ore", "Dense unrefined iron-rich mineral vein chunk.", 99, 1.2, 5)
	_create_resource(&"gold_ore", "Gold Ore", "Glittering precious mineral chunk, highly prized for advanced crafting.", 99, 1.5, 15)
	_create_resource(&"flint", "Flint Stone", "Hard, sharp sedimentary mineral used for starting fires and fletching arrowheads.", 99, 0.4, 3)
	_create_resource(&"coal", "Lump of Coal", "Combustible black mineral used for high-temperature smelting and torches.", 99, 0.5, 4)
	_create_resource(&"fiber", "Plant Fiber", "Flexible fibrous plant strands used for weaving twine, cordage, and light apparel.", 99, 0.1, 1)
	_create_resource(&"clay", "Wet Clay", "Malleable earth suitable for pottery, bricks, and furnace masonry.", 99, 0.6, 2)
	_create_resource(&"stick", "Wooden Stick", "A slender piece of wood suitable for crafting tools, arrows, and kindling.", 99, 0.2, 1)

	# Subterranean Gems & Ores
	_create_resource(&"ruby", "Crimson Ruby", "Flawless precious gemstone found deep in subterranean chasms.", 99, 0.2, 50)
	_create_resource(&"sapphire", "Deep Sapphire", "Gleaming blue crystal resonating with arcane subterranean energy.", 99, 0.2, 50)
	_create_resource(&"mythril_ore", "Mythril Ore", "Luminescent sky-blue metal ore of immense tensile strength.", 99, 1.4, 25)
	_create_resource(&"mythril_ingot", "Mythril Ingot", "Super-refined lightweight metal bar forged from subterranean mythril.", 99, 0.8, 80)
	_create_resource(&"spider_fang", "Arachnid Fang", "Venom-infused chitinous fang harvested from cave spiders.", 99, 0.1, 12)

	# 2. Foraged Food & Crops
	_create_food(&"berries", "Sweet Berries", "Handful of ripe wild forest berries. Restores hunger and a pinch of stamina.", 50, 0.1, 1, 2.0, 5.0, 8.0)
	_create_food(&"apple", "Crisp Apple", "A juicy wild orchard apple, rich in natural sugars and moisture.", 30, 0.2, 3, 5.0, 10.0, 12.0)
	_create_food(&"healing_herb", "Healing Herb", "Potent medicinal leaves that soothe wounds and rapidly regenerate health.", 30, 0.1, 8, 25.0, 0.0, 0.0)
	_create_food(&"raw_meat", "Raw Meat", "Uncooked animal meat. Edible in emergencies, but risky when raw.", 30, 0.5, 3, -5.0, 0.0, 20.0)
	_create_food(&"cooked_meat", "Roasted Steak", "Delicious seasoned roasted meat cooked over fire. Excellent nourishment.", 30, 0.5, 12, 15.0, 20.0, 50.0)
	_create_food(&"wheat", "Harvested Wheat", "Golden sheaves of wheat ready to be ground into flour or traded.", 99, 0.2, 4, 0.0, 0.0, 5.0)
	_create_food(&"spoiled_matter", "Spoiled Matter", "Decomposed organic rot. Inedible, but can be used as fertilizer.", 50, 0.3, 0, -15.0, -10.0, 0.0)

	# Seeds
	_create_resource(&"seed_wheat", "Wheat Seeds", "Viable grain kernels that can be planted in tilled farm soil.", 99, 0.05, 2)
	_create_resource(&"seed_carrot", "Carrot Seeds", "Heirloom root vegetable seeds for farming.", 99, 0.05, 3)
	_create_resource(&"seed_herb", "Herb Seeds", "Medicinal botanical seeds for cultivating healing herbs.", 99, 0.05, 5)

	# 3. Gathering Tools
	_create_tool(&"stone_axe", "Stone Axe", "A primitive handaxe bound with rope. Effective at felling trees.", ItemDefinition.ToolType.AXE, 2, 12.0, 1.1, 100, 15)
	_create_tool(&"iron_axe", "Iron Axe", "A finely forged iron axe capable of cutting the densest hard timber swiftly.", ItemDefinition.ToolType.AXE, 3, 22.0, 1.3, 250, 45)
	_create_tool(&"stone_pickaxe", "Stone Pickaxe", "A sturdy chisel pick for breaking rocks and harvesting raw stone.", ItemDefinition.ToolType.PICKAXE, 2, 10.0, 1.0, 100, 15)
	_create_tool(&"iron_pickaxe", "Iron Pickaxe", "Heavy iron pickaxe designed to extract tough metal ores cleanly.", ItemDefinition.ToolType.PICKAXE, 3, 20.0, 1.2, 250, 45)
	_create_tool(&"mythril_pickaxe", "Mythril Pickaxe", "Masterwork subterranean mining pick that shatters the hardest crystals.", ItemDefinition.ToolType.PICKAXE, 4, 32.0, 1.5, 500, 150)

	# 4. Weapons
	_create_weapon(&"wooden_sword", "Wooden Club", "A carved blunt wooden club for fending off nocturnal beasts.", 14.0, 1.2, 45.0, 80, 10)
	_create_weapon(&"stone_sword", "Stone Blade", "A knapped stone dagger with serrated edge. Moderate damage.", 20.0, 1.4, 48.0, 120, 20)
	_create_weapon(&"iron_sword", "Iron Broadsword", "A sharp balanced steel blade delivering deadly sweeping slashes.", 32.0, 1.5, 52.0, 250, 60)
	_create_weapon(&"spider_dagger", "Arachnid Venom Dagger", "A swift curved dagger coated in paralyzing neurotoxin.", 28.0, 1.8, 42.0, 200, 90)
	_create_weapon(&"hunting_bow", "Hunting Bow", "A flexible wooden curved bow capable of launching arrows at distance.", 25.0, 0.9, 250.0, 150, 40)
	_create_resource(&"arrow", "Flint Arrow", "Feathered wooden projectile tipped with razor flint.", 99, 0.05, 1)

	# 5. Armor & Equipment
	_create_armor(&"leather_cap", "Leather Cap", "Supple hardened leather headwear offering basic thermal protection.", ItemDefinition.EquipmentSlotType.HEAD, 2.0, 0.0, 5.0, 100, 20)
	_create_armor(&"leather_tunic", "Leather Tunic", "Reinforced hide armor protecting the torso from claws and fangs.", ItemDefinition.EquipmentSlotType.CHEST, 5.0, 0.0, 15.0, 150, 35)
	_create_armor(&"leather_boots", "Leather Boots", "Sturdy exploration boots providing enhanced sprinting endurance.", ItemDefinition.EquipmentSlotType.FEET, 2.0, 10.0, 5.0, 120, 25)
	_create_armor(&"iron_chestplate", "Iron Chestplate", "Heavy polished metal plate armor granting substantial defense.", ItemDefinition.EquipmentSlotType.CHEST, 14.0, -5.0, 30.0, 300, 100)
	_create_armor(&"silk_robe", "Shadow Silk Robe", "Woven from Broodmother silk, granting incredible agility and warding.", ItemDefinition.EquipmentSlotType.CHEST, 10.0, 15.0, 20.0, 250, 120)

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
