class_name TestResourceGathering
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_axe_on_tree_damage())
	results.append(_test_ineffective_tool_damage())
	results.append(_test_tool_tier_scaling())
	results.append(_test_node_depletion())
	return results

func _test_axe_on_tree_damage() -> Dictionary:
	var tree: TreeNode = TreeNode.new()
	tree._ready()
	# Stone axe (Axe, Tier 2, 12 DMG) vs Oak Tree (Tier 1 requirement)
	# Tier scaling: 12 * (1.0 + (2 - 1) * 0.35) = 12 * 1.35 = 16.2
	var dmg: float = tree.calculate_damage(12.0, ItemDefinition.ToolType.AXE, 2)
	var passed: bool = is_equal_approx(dmg, 16.2)
	tree.free()
	return {"name": "Resource Gathering: Axe vs Tree Damage", "passed": passed, "message": "Expected 16.2 dmg, got %f" % dmg}

func _test_ineffective_tool_damage() -> Dictionary:
	var tree: TreeNode = TreeNode.new()
	tree._ready()
	# Pickaxe against tree -> Ineffective tool returns 1.5 min dmg
	var dmg: float = tree.calculate_damage(15.0, ItemDefinition.ToolType.PICKAXE, 2)
	var passed: bool = (dmg == 1.5)
	tree.free()
	return {"name": "Resource Gathering: Ineffective Tool Penalty", "passed": passed, "message": "Expected 1.5 dmg, got %f" % dmg}

func _test_tool_tier_scaling() -> Dictionary:
	var rock: RockNode = RockNode.new()
	rock._ready()
	# Stone Pickaxe (Tier 2, 10 DMG): 10 * (1 + 0.35) = 13.5
	var dmg_tier2: float = rock.calculate_damage(10.0, ItemDefinition.ToolType.PICKAXE, 2)
	# Iron Pickaxe (Tier 3, 20 DMG): 20 * (1 + 2 * 0.35) = 20 * 1.7 = 34.0
	var dmg_tier3: float = rock.calculate_damage(20.0, ItemDefinition.ToolType.PICKAXE, 3)
	var passed: bool = is_equal_approx(dmg_tier2, 13.5) and is_equal_approx(dmg_tier3, 34.0)
	rock.free()
	return {"name": "Resource Gathering: Tool Tier Scaling", "passed": passed, "message": "Tier2: %f, Tier3: %f" % [dmg_tier2, dmg_tier3]}

func _test_node_depletion() -> Dictionary:
	var bush: BushNode = BushNode.new()
	bush._ready()
	# Bush has 15 HP
	bush.hit(10.0, ItemDefinition.ToolType.NONE, 0, null)
	var not_depleted: bool = not bush.is_depleted and (bush.current_health == 5.0)
	bush.hit(10.0, ItemDefinition.ToolType.NONE, 0, null)
	var is_depleted: bool = bush.is_depleted and (bush.current_health <= 0.0)
	bush.free()
	return {"name": "Resource Gathering: Node Health & Depletion", "passed": not_depleted and is_depleted, "message": "Depletion triggers accurately"}
