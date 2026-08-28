class_name TestMagicAndSpells
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_mana_drain_and_regen())
	results.append(_test_spell_database_lookup())
	return results

func _test_mana_drain_and_regen() -> Dictionary:
	var mana: ManaAttribute = ManaAttribute.new()
	mana.base_mana = 100.0
	mana.current_mana = 100.0
	mana.mana_regen_rate = 10.0
	
	var spent: bool = mana.spend_mana(40.0)
	var left: float = mana.current_mana # 60.0
	
	mana.update_mana(2.0) # +20 MP -> 80.0
	var regened: float = mana.current_mana
	
	var passed: bool = spent and is_equal_approx(left, 60.0) and is_equal_approx(regened, 80.0)
	return {"name": "Magic: Mana Drain & Natural Regeneration", "passed": passed, "message": "Spent 40 MP, regened 20 MP"}

func _test_spell_database_lookup() -> Dictionary:
	var fb: SpellDefinition = SpellDatabase.get_spell(&"spell_fireball")
	var passed: bool = (fb != null) and (fb.damage == 45.0) and (fb.mana_cost == 25.0)
	return {"name": "Magic: Spell Database Registry", "passed": passed, "message": "Fireball damage: 45, cost: 25 MP"}
