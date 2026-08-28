class_name GuardianDatabase
extends RefCounted

static var _guardians: Dictionary = {
	&"abyssal_leviathan": { "name": "Leviathan of the Abyss", "hp": 1200.0, "armor": 8.0, "element": "Water", "xp": 800 },
	&"void_cthulhu": { "name": "Cthulhu Void Walker", "hp": 1500.0, "armor": 10.0, "element": "Void", "xp": 1000 },
	&"ancient_automaton": { "name": "Ancient Automaton Golem", "hp": 1000.0, "armor": 12.0, "element": "Tech", "xp": 750 },
	&"frost_wyrm": { "name": "Frost Wyrm Ymir", "hp": 1100.0, "armor": 7.0, "element": "Frost", "xp": 850 },
	&"shadow_lord": { "name": "Shadow Lord Malakor", "hp": 1350.0, "armor": 9.0, "element": "Shadow", "xp": 900 },
	&"thunderbird": { "name": "Thunderbird Stormbringer", "hp": 950.0, "armor": 6.0, "element": "Lightning", "xp": 700 },
	&"magma_dragon": { "name": "Infernal Magma Dragon", "hp": 1600.0, "armor": 11.0, "element": "Fire", "xp": 1200 },
	&"venom_hydra": { "name": "Venomous Hydra", "hp": 1250.0, "armor": 7.5, "element": "Poison", "xp": 850 },
	&"crystal_archon": { "name": "Crystal Archon", "hp": 1400.0, "armor": 10.0, "element": "Arcane", "xp": 950 },
	&"eclipse_devourer": { "name": "Omega Eclipse Devourer", "hp": 2000.0, "armor": 15.0, "element": "Cosmic", "xp": 2000 }
}

static func get_guardian(id: StringName) -> Dictionary:
	return _guardians.get(id, {})

static func get_all_guardians() -> Dictionary:
	return _guardians

static func count() -> int:
	return _guardians.size()
