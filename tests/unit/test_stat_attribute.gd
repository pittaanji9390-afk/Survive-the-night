class_name TestStatAttribute
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_base_value())
	results.append(_test_flat_modifier())
	results.append(_test_percentage_modifiers())
	results.append(_test_clamping_and_depletion())
	results.append(_test_remove_modifier())
	return results

func _test_base_value() -> Dictionary:
	var stat: StatAttribute = StatAttribute.new(&"Health", 100.0)
	var passed: bool = (stat.get_max_value() == 100.0) and (stat.get_current_value() == 100.0)
	return {"name": "StatAttribute: Base Value Initialized", "passed": passed, "message": "Expected 100.0, got %f" % stat.get_max_value()}

func _test_flat_modifier() -> Dictionary:
	var stat: StatAttribute = StatAttribute.new(&"Health", 100.0)
	stat.add_modifier("bonus_health", 50.0, StatAttribute.ModifierType.FLAT)
	var passed: bool = (stat.get_max_value() == 150.0)
	return {"name": "StatAttribute: Flat Modifier", "passed": passed, "message": "Expected 150.0, got %f" % stat.get_max_value()}

func _test_percentage_modifiers() -> Dictionary:
	var stat: StatAttribute = StatAttribute.new(&"Speed", 100.0)
	# +50% additive
	stat.add_modifier("buff_speed", 0.5, StatAttribute.ModifierType.PERCENT_ADDITIVE)
	var passed: bool = is_equal_approx(stat.get_max_value(), 150.0)
	
	# +20% multiplicative: 150 * 1.2 = 180.0
	stat.add_modifier("mult_speed", 0.2, StatAttribute.ModifierType.PERCENT_MULTIPLICATIVE)
	passed = passed and is_equal_approx(stat.get_max_value(), 180.0)
	
	return {"name": "StatAttribute: Percentage Modifiers", "passed": passed, "message": "Expected 180.0, got %f" % stat.get_max_value()}

func _test_clamping_and_depletion() -> Dictionary:
	var stat: StatAttribute = StatAttribute.new(&"Stamina", 100.0)
	stat.set_current(150.0) # Should clamp to 100.0
	var passed: bool = (stat.get_current_value() == 100.0)
	
	stat.modify_current(-120.0) # Should clamp to 0.0
	passed = passed and (stat.get_current_value() == 0.0)
	
	return {"name": "StatAttribute: Clamping & Depletion", "passed": passed, "message": "Current: %f" % stat.get_current_value()}

func _test_remove_modifier() -> Dictionary:
	var stat: StatAttribute = StatAttribute.new(&"Health", 100.0)
	stat.add_modifier("gear_hp", 30.0, StatAttribute.ModifierType.FLAT)
	var with_mod: bool = (stat.get_max_value() == 130.0)
	stat.remove_modifier("gear_hp")
	var without_mod: bool = (stat.get_max_value() == 100.0)
	return {"name": "StatAttribute: Remove Modifier", "passed": with_mod and without_mod, "message": "With: %f, Without: %f" % [130.0, stat.get_max_value()]}
