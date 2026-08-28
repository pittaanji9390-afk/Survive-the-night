class_name TestBuildingSystem
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_structure_costs_and_consumption())
	results.append(_test_structure_damage_and_armor())
	results.append(_test_structure_repair())
	results.append(_test_door_toggle())
	results.append(_test_chest_storage_transfer())
	results.append(_test_deconstruction_refund())
	return results

func _test_structure_costs_and_consumption() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	var def: StructureDefinition = StructureDatabase.get_structure(&"wood_wall")
	
	# Wall requires 4 wood, 2 wooden_plank
	var cannot_afford: bool = not def.can_build(inv)
	
	inv.add_item(&"wood", 4)
	inv.add_item(&"wooden_plank", 2)
	var can_afford: bool = def.can_build(inv)
	
	def.consume_costs(inv)
	var wood_left: int = inv.get_item_count(&"wood")
	var planks_left: int = inv.get_item_count(&"wooden_plank")
	var consumed_ok: bool = (wood_left == 0) and (planks_left == 0)
	
	var passed: bool = cannot_afford and can_afford and consumed_ok
	inv.free()
	return {"name": "Building: Cost Verification & Consumption", "passed": passed, "message": "Cost checks & deduction accurate"}

func _test_structure_damage_and_armor() -> Dictionary:
	var wall: StructureInstance = StructureInstance.new()
	wall.structure_id = &"stone_wall_struct"
	wall._ready()
	# Stone wall has 350 HP and 5.0 Armor
	# 25 raw damage - 5 armor = 20 effective damage -> 330 HP remaining
	var taken: float = wall.take_damage(25.0, null)
	var passed: bool = is_equal_approx(taken, 20.0) and is_equal_approx(wall.current_health, 330.0)
	wall.free()
	return {"name": "Building: Structure Damage & Armor Mitigation", "passed": passed, "message": "Expected 20 damage, got %f" % taken}

func _test_structure_repair() -> Dictionary:
	var wall: StructureInstance = StructureInstance.new()
	wall.structure_id = &"wood_wall"
	wall._ready()
	wall.take_damage(50.0, null) # 150 - 49 = 101 HP
	var damaged_hp: float = wall.current_health
	
	wall.repair(30.0)
	var repaired_hp: float = wall.current_health
	var passed: bool = is_equal_approx(repaired_hp, damaged_hp + 30.0)
	wall.free()
	return {"name": "Building: Structure Repair", "passed": passed, "message": "Repaired from %f to %f" % [damaged_hp, repaired_hp]}

func _test_door_toggle() -> Dictionary:
	var door: DoorStructure = DoorStructure.new()
	door._ready()
	var initial_closed: bool = not door.is_open
	door.toggle_door()
	var now_open: bool = door.is_open
	door.toggle_door()
	var now_closed_again: bool = not door.is_open
	
	var passed: bool = initial_closed and now_open and now_closed_again
	door.free()
	return {"name": "Building: Interactive Door Toggle", "passed": passed, "message": "Door open/close state toggled properly"}

func _test_chest_storage_transfer() -> Dictionary:
	var chest: ChestStructure = ChestStructure.new()
	chest._ready()
	
	var player_inv: InventoryContainer = InventoryContainer.new(10)
	player_inv.add_item(&"iron_ingot", 8)
	
	# Transfer 5 iron ingots into chest
	var rem: int = chest.container.add_item(&"iron_ingot", 5)
	player_inv.remove_item(&"iron_ingot", 5)
	
	var passed: bool = (rem == 0) and (chest.container.get_item_count(&"iron_ingot") == 5) and (player_inv.get_item_count(&"iron_ingot") == 3)
	chest.free()
	player_inv.free()
	return {"name": "Building: Chest Storage Transfer", "passed": passed, "message": "Chest storage transfer verified"}

func _test_deconstruction_refund() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	var def: StructureDefinition = StructureDatabase.get_structure(&"wood_wall")
	# Wood wall costs 4 wood, 2 planks -> 50% refund is 2 wood, 1 plank
	def.refund_costs(inv)
	var wood_refund: int = inv.get_item_count(&"wood")
	var plank_refund: int = inv.get_item_count(&"wooden_plank")
	
	var passed: bool = (wood_refund == 2) and (plank_refund == 1)
	inv.free()
	return {"name": "Building: Deconstruction Resource Refund", "passed": passed, "message": "Refunded 2 wood and 1 plank"}
