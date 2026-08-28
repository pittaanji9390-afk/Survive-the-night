class_name SpellDatabase
extends RefCounted

static var _spells: Dictionary = {}
static var _initialized: bool = false

static func get_spell(id: StringName) -> SpellDefinition:
	_ensure_initialized()
	return _spells.get(id, null)

static func get_all_spells() -> Array[SpellDefinition]:
	_ensure_initialized()
	var list: Array[SpellDefinition] = []
	for k in _spells:
		list.append(_spells[k])
	return list

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_populate_default_spells()

static func _populate_default_spells() -> void:
	_add_spell(&"spell_fireball", "Pyroclastic Fireball", SpellDefinition.ElementType.FIRE, 25.0, 45.0, 1.2, 40.0)
	_add_spell(&"spell_frost_nova", "Frost Nova", SpellDefinition.ElementType.FROST, 30.0, 30.0, 2.0, 60.0)
	_add_spell(&"spell_lightning", "Chain Lightning", SpellDefinition.ElementType.LIGHTNING, 35.0, 55.0, 1.8, 20.0)
	_add_spell(&"spell_heal_bloom", "Healing Blossom", SpellDefinition.ElementType.NATURE, 20.0, -35.0, 3.0, 30.0)

static func _add_spell(id: StringName, name: String, elem: SpellDefinition.ElementType, cost: float, dmg: float, cd: float, aoe: float) -> void:
	var s: SpellDefinition = SpellDefinition.new()
	s.spell_id = id
	s.spell_name = name
	s.element = elem
	s.mana_cost = cost
	s.damage = dmg
	s.cooldown_sec = cd
	s.aoe_radius = aoe
	_spells[id] = s
