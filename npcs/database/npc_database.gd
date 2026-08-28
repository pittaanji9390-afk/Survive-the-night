class_name NPCDatabase
extends RefCounted

static var _npcs: Dictionary = {}
static var _initialized: bool = false

static func get_npc(id: StringName) -> NPCDefinition:
	_ensure_initialized()
	if _npcs.has(id):
		return _npcs[id]
	return null

static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_populate_default_npcs()

static func _populate_default_npcs() -> void:
	# 1. Elder Roderick
	var elder: NPCDefinition = NPCDefinition.new()
	elder.npc_id = &"npc_elder"
	elder.npc_name = "Elder Roderick"
	elder.role_title = "Sanctuary Elder"
	elder.dialogue_lines = [
		"Greetings, survivor. The darkness here is not ordinary—it hungers.",
		"Gather timber and build sturdy walls before nightfall.",
		"When the Blood Moon rises every fifth night, prepare your blades and barricades."
	]
	elder.trade_offers = [
		{ "cost_id": &"wood", "cost_count": 8, "reward_id": &"seed_wheat", "reward_count": 3 },
		{ "cost_id": &"berries", "cost_count": 10, "reward_id": &"arrow", "reward_count": 15 }
	]
	_npcs[elder.npc_id] = elder

	# 2. Blacksmith Fiona
	var smith: NPCDefinition = NPCDefinition.new()
	smith.npc_id = &"npc_smith"
	smith.npc_name = "Blacksmith Fiona"
	smith.role_title = "Master Forger"
	smith.dialogue_lines = [
		"Need sharp steel? Bring me raw iron ore and coal.",
		"Good armor will keep your ribs intact against those howling dire wolves."
	]
	smith.trade_offers = [
		{ "cost_id": &"iron_ore", "cost_count": 4, "reward_id": &"iron_ingot", "reward_count": 2 },
		{ "cost_id": &"stone", "cost_count": 15, "reward_id": &"iron_sword", "reward_count": 1 }
	]
	_npcs[smith.npc_id] = smith
