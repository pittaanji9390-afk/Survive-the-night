class_name NPCDefinition
extends Resource

@export var npc_id: StringName = &"npc_elder"
@export var npc_name: String = "Elder Roderick"
@export var role_title: String = "Village Guardian"

@export var dialogue_lines: Array[String] = []

# Array of trade offers: [{ "cost_id": StringName, "cost_count": int, "reward_id": StringName, "reward_count": int }]
@export var trade_offers: Array[Dictionary] = []
