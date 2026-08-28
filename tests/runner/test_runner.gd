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
const TestSurvivalMechanicsScript = preload("res://tests/unit/test_survival_mechanics.gd")
const TestWaveManagerScript = preload("res://tests/unit/test_wave_manager.gd")
const TestWorldGenerationScript = preload("res://tests/unit/test_world_generation.gd")
const TestFarmingSystemScript = preload("res://tests/unit/test_farming_system.gd")
const TestNPCAndTradingScript = preload("res://tests/unit/test_npc_and_trading.gd")
const TestProgressionAndSkillsScript = preload("res://tests/unit/test_progression_and_skills.gd")
const TestBossEncounterScript = preload("res://tests/unit/test_boss_encounter.gd")
const TestSaveLoadSystemScript = preload("res://tests/unit/test_save_load_system.gd")
const TestQuestSystemScript = preload("res://tests/unit/test_quest_system.gd")
const TestDungeonGenerationScript = preload("res://tests/unit/test_dungeon_generation.gd")
const TestDungeonMechanicsScript = preload("res://tests/unit/test_dungeon_mechanics.gd")
const TestPowerGridScript = preload("res://tests/unit/test_power_grid.gd")
const TestFactoryAutomationScript = preload("res://tests/unit/test_factory_automation.gd")
const TestCompanionTamingScript = preload("res://tests/unit/test_companion_taming.gd")
const TestSeasonsAndWeatherScript = preload("res://tests/unit/test_seasons_and_weather.gd")
const TestTitanWorldBossScript = preload("res://tests/unit/test_titan_world_boss.gd")
const TestColonySimulationScript = preload("res://tests/unit/test_colony_simulation.gd")
const TestMagicAndSpellsScript = preload("res://tests/unit/test_magic_and_spells.gd")
const TestNavalSystemsScript = preload("res://tests/unit/test_naval_systems.gd")
const TestFluidLogisticsScript = preload("res://tests/unit/test_fluid_logistics.gd")
const TestFactionDiplomacyScript = preload("res://tests/unit/test_faction_diplomacy.gd")
const TestBSPDungeonScript = preload("res://tests/unit/test_bsp_dungeon.gd")
const TestVehiclesAndTrainsScript = preload("res://tests/unit/test_vehicles_and_trains.gd")
const TestArcadeGamesScript = preload("res://tests/unit/test_arcade_games.gd")
const TestMoreArcadeGamesScript = preload("res://tests/unit/test_more_arcade_games.gd")

func _ready() -> void:
	print("========================================")
	print("   SURVIVE THE NIGHT - GRAND QA SUITE")
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
		TestCombatSystemScript.new(),
		TestSurvivalMechanicsScript.new(),
		TestWaveManagerScript.new(),
		TestWorldGenerationScript.new(),
		TestFarmingSystemScript.new(),
		TestNPCAndTradingScript.new(),
		TestProgressionAndSkillsScript.new(),
		TestBossEncounterScript.new(),
		TestSaveLoadSystemScript.new(),
		TestQuestSystemScript.new(),
		TestDungeonGenerationScript.new(),
		TestDungeonMechanicsScript.new(),
		TestPowerGridScript.new(),
		TestFactoryAutomationScript.new(),
		TestCompanionTamingScript.new(),
		TestSeasonsAndWeatherScript.new(),
		TestTitanWorldBossScript.new(),
		TestColonySimulationScript.new(),
		TestMagicAndSpellsScript.new(),
		TestNavalSystemsScript.new(),
		TestFluidLogisticsScript.new(),
		TestFactionDiplomacyScript.new(),
		TestBSPDungeonScript.new(),
		TestVehiclesAndTrainsScript.new(),
		TestArcadeGamesScript.new(),
		TestMoreArcadeGamesScript.new()
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
		push_error("Grand test suite finished with %d failures." % failed_tests)
