class_name TestInventory
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_add_and_stack_items())
	results.append(_test_stack_overflow_new_slot())
	results.append(_test_remove_items())
	results.append(_test_swap_and_merge_slots())
	results.append(_test_split_slot())
	results.append(_test_total_weight_calculation())
	results.append(_test_serialization())
	return results

func _test_add_and_stack_items() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	var rem: int = inv.add_item(&"wood", 50)
	var passed: bool = (rem == 0) and (inv.get_item_count(&"wood") == 50) and (inv.slots[0].quantity == 50)
	
	# Add 30 more to the same stack
	rem = inv.add_item(&"wood", 30)
	passed = passed and (rem == 0) and (inv.slots[0].quantity == 80) and (inv.get_item_count(&"wood") == 80)
	inv.free()
	return {"name": "Inventory: Add & Stack Items", "passed": passed, "message": "Expected 80 wood in slot 0"}

func _test_stack_overflow_new_slot() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.add_item(&"wood", 80)
	# Adding 30 more should fill slot 0 to 99 and put 11 in slot 1
	var rem: int = inv.add_item(&"wood", 30)
	var passed: bool = (rem == 0) and (inv.slots[0].quantity == 99) and (inv.slots[1].quantity == 11) and (inv.get_item_count(&"wood") == 110)
	inv.free()
	return {"name": "Inventory: Stack Overflow to Next Slot", "passed": passed, "message": "Slot 0: %d, Slot 1: %d" % [99, 11]}

func _test_remove_items() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.add_item(&"wood", 50)
	inv.add_item(&"stone", 20)
	
	var removed: bool = inv.remove_item(&"wood", 30)
	var passed: bool = removed and (inv.get_item_count(&"wood") == 20) and (inv.get_item_count(&"stone") == 20)
	
	var failed_remove: bool = not inv.remove_item(&"wood", 50) # Not enough wood
	passed = passed and failed_remove and (inv.get_item_count(&"wood") == 20)
	inv.free()
	return {"name": "Inventory: Remove Items & Count Guard", "passed": passed, "message": "Expected 20 wood remaining"}

func _test_swap_and_merge_slots() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.slots[0].set_item(&"wood", 20)
	inv.slots[1].set_item(&"stone", 10)
	
	# Swap slots 0 and 1
	inv.swap_slots(0, 1)
	var passed: bool = (inv.slots[0].item_id == &"stone") and (inv.slots[1].item_id == &"wood")
	
	# Test merging same items
	inv.slots[2].set_item(&"wood", 30)
	inv.swap_slots(1, 2) # Merge slot 1 (20 wood) into slot 2 (30 wood) -> slot 2 becomes 50 wood, slot 1 becomes empty
	passed = passed and (inv.slots[2].quantity == 50) and (inv.slots[1].is_empty())
	inv.free()
	return {"name": "Inventory: Swap & Merge Slots", "passed": passed, "message": "Slot 2 should have 50 wood"}

func _test_split_slot() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.slots[0].set_item(&"wood", 50)
	var split_success: bool = inv.split_slot(0, 1, 20) # Move 20 wood to slot 1
	var passed: bool = split_success and (inv.slots[0].quantity == 30) and (inv.slots[1].quantity == 20)
	inv.free()
	return {"name": "Inventory: Split Stack", "passed": passed, "message": "Slot 0: 30, Slot 1: 20"}

func _test_total_weight_calculation() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	# Wood weight = 0.4kg, Stone weight = 0.8kg
	inv.add_item(&"wood", 10)  # 4.0 kg
	inv.add_item(&"stone", 5)  # 4.0 kg
	var wt: float = inv.get_total_weight()
	var passed: bool = is_equal_approx(wt, 8.0)
	inv.free()
	return {"name": "Inventory: Weight Calculation", "passed": passed, "message": "Expected 8.0kg, got %f" % wt}

func _test_serialization() -> Dictionary:
	var inv_a: InventoryContainer = InventoryContainer.new(5)
	inv_a.add_item(&"stone_axe", 1, 95)
	inv_a.add_item(&"wood", 42)
	
	var data: Array[Dictionary] = inv_a.serialize()
	
	var inv_b: InventoryContainer = InventoryContainer.new(5)
	inv_b.deserialize(data)
	
	var passed: bool = (inv_b.slots[0].item_id == &"stone_axe") and (inv_b.slots[0].durability == 95) and (inv_b.slots[1].quantity == 42)
	inv_a.free()
	inv_b.free()
	return {"name": "Inventory: Serialization & Deserialization", "passed": passed, "message": "Deserialized accurately"}
