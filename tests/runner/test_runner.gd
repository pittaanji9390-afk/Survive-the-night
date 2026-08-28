class_name TestRunner
extends Node

const TestStatAttributeScript = preload("res://tests/unit/test_stat_attribute.gd")
const TestTimeManagerScript = preload("res://tests/unit/test_time_manager.gd")
const TestGameStateScript = preload("res://tests/unit/test_game_state.gd")
const TestInventoryScript = preload("res://tests/unit/test_inventory.gd")
const TestResourceGatheringScript = preload("res://tests/unit/test_resource_gathering.gd")
const TestCraftingRecipesScript = preload("res://tests/unit/test_crafting_recipes.gd")
const TestTechTreeScript = preload("res://tests/unit/test_tech_tree.gd")
const TestBuildingSystemScript = preload("res://tests/unit/test_building_system.gd")
const TestCombatSystemScript = preload("res://tests/unit/test_combat_system.gd")

func _ready() -> void:
	print("========================================")
	print("   SURVIVE THE NIGHT - TEST SUITE")
	print("========================================")
	
	var total_tests: int = 0
	var passed_tests: int = 0
	var failed_tests: int = 0
	
	var suites: Array = [
		TestStatAttributeScript.new(),
		TestTimeManagerScript.new(),
		TestGameStateScript.new(),
		TestInventoryScript.new(),
		TestResourceGatheringScript.new(),
		TestCraftingRecipesScript.new(),
		TestTechTreeScript.new(),
		TestBuildingSystemScript.new(),
		TestCombatSystemScript.new()
	]
	
	for suite in suites:
		var results: Array[Dictionary] = suite.run_all()
		for res in results:
			total_tests += 1
			if res.passed:
				passed_tests += 1
				print("[PASS] %s" % res.name)
			else:
				failed_tests += 1
				print("[FAIL] %s -> %s" % [res.name, res.message])
	
	print("----------------------------------------")
	print("RESULTS: %d Total | %d Passed | %d Failed" % [total_tests, passed_tests, failed_tests])
	print("========================================")
	
	if failed_tests > 0:
		push_error("Test suite finished with %d failures." % failed_tests)
