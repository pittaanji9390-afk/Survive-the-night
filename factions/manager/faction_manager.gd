class_name FactionManager
extends Node

signal faction_reputation_changed(faction_id: StringName, new_rep: int, stance: FactionDefinition.FactionStance)

var _factions: Dictionary = {}

func _ready() -> void:
	ServiceLocator.register_service(&"FactionManager", self)
	_setup_default_factions()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"FactionManager")

func _setup_default_factions() -> void:
	_add_faction(&"faction_iron_vanguard", "Iron Vanguard", 0)
	_add_faction(&"faction_sylvan_druids", "Sylvan Druids", 15)
	_add_faction(&"faction_shadow_coven", "Shadow Coven", -40)
	_add_faction(&"faction_nomad_caravan", "Nomad Caravan", 20)

func _add_faction(id: StringName, name: String, rep: int) -> void:
	var f: FactionDefinition = FactionDefinition.new()
	f.faction_id = id
	f.faction_name = name
	f.reputation = rep
	_factions[id] = f

func get_faction(id: StringName) -> FactionDefinition:
	return _factions.get(id, null)

func modify_reputation(id: StringName, delta: int) -> void:
	if _factions.has(id):
		var f: FactionDefinition = _factions[id]
		f.modify_reputation(delta)
		faction_reputation_changed.emit(id, f.reputation, f.get_stance())
		EventBus.notification_posted.emit("Faction Relations", "%s rep: %d" % [f.faction_name, f.reputation], "flag")
