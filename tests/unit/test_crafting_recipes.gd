class_name TestCraftingRecipes
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_recipe_validation())
	results.append(_test_max_craftable_calculation())
	results.append(_test_ingredient_consumption_and_production())
	results.append(_test_ingredient_refund())
	results.append(_test_crafting_queue_simulation())
	return results

func _test_recipe_validation() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	var rec: CraftingRecipe = RecipeDatabase.get_recipe(&"craft_wooden_plank")
	
	var cannot_craft: bool = not rec.can_craft_with_inventory(inv, CraftingRecipe.StationType.HAND)
	
	inv.add_item(&"wood", 1)
	var can_craft: bool = rec.can_craft_with_inventory(inv, CraftingRecipe.StationType.HAND)
	
	inv.free()
	return {"name": "Crafting: Recipe Ingredient Validation", "passed": cannot_craft and can_craft, "message": "Validation accurate"}

func _test_max_craftable_calculation() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.add_item(&"stone", 6)
	inv.add_item(&"stick", 4)
	inv.add_item(&"rope", 2)
	
	var rec: CraftingRecipe = RecipeDatabase.get_recipe(&"craft_stone_axe")
	var count: int = rec.get_max_craftable_count(inv, CraftingRecipe.StationType.HAND)
	var passed: bool = (count == 2)
	var msg: String = "Expected 2, got %d" % count
	inv.free()
	return {"name": "Crafting: Max Craftable Count Calculation", "passed": passed, "message": msg}

func _test_ingredient_consumption_and_production() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.add_item(&"wood", 3)
	
	var rec: CraftingRecipe = RecipeDatabase.get_recipe(&"craft_wooden_plank")
	var consumed: bool = rec.consume_ingredients(inv)
	var produced: Array[Dictionary] = rec.produce_results(inv)
	
	var plank_count: int = inv.get_item_count(&"wooden_plank")
	var wood_count: int = inv.get_item_count(&"wood")
	var passed: bool = consumed and (wood_count == 2) and (plank_count == 4) and (produced.size() == 1)
	var msg: String = "Produced %d planks, %d wood left" % [plank_count, wood_count]
	inv.free()
	return {"name": "Crafting: Ingredient Consumption & Production", "passed": passed, "message": msg}

func _test_ingredient_refund() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.add_item(&"wood", 5)
	
	var rec: CraftingRecipe = RecipeDatabase.get_recipe(&"craft_wooden_plank")
	rec.consume_ingredients(inv)
	rec.refund_ingredients(inv)
	
	var wood_count: int = inv.get_item_count(&"wood")
	var passed: bool = (wood_count == 5)
	var msg: String = "Expected 5 wood, got %d" % wood_count
	inv.free()
	return {"name": "Crafting: Ingredient Refund on Cancel", "passed": passed, "message": msg}

func _test_crafting_queue_simulation() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.add_item(&"wood", 10)
	
	var queue: CraftingQueue = CraftingQueue.new()
	queue._inventory = inv
	
	var rec: CraftingRecipe = RecipeDatabase.get_recipe(&"craft_wooden_plank")
	var queued: bool = queue.queue_recipe(rec, 2, CraftingRecipe.StationType.HAND)
	var wood_after_queue: int = inv.get_item_count(&"wood")
	
	queue._process(1.5)
	var planks_mid: int = inv.get_item_count(&"wooden_plank")
	
	queue._process(1.5)
	var planks_final: int = inv.get_item_count(&"wooden_plank")
	var queue_empty: bool = queue.queue.is_empty()
	
	var passed: bool = queued and (wood_after_queue == 8) and (planks_mid == 4) and (planks_final == 8) and queue_empty
	var msg: String = "Final planks: %d, Queue empty: %s" % [planks_final, queue_empty]
	
	inv.free()
	queue.free()
	return {"name": "Crafting: Queue Batch Progression", "passed": passed, "message": msg}
