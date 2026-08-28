class_name RockNode
extends ResourceNode

func _ready() -> void:
	node_name = "Stone Boulder"
	node_type = NodeType.ROCK
	max_health = 50.0
	required_tool_type = ItemDefinition.ToolType.PICKAXE
	required_tool_tier = 1
	respawn_time_sec = 80.0
	
	loot_table = [
		{ "id": &"stone", "min": 3, "max": 7, "chance": 1.0 },
		{ "id": &"flint", "min": 1, "max": 2, "chance": 0.6 },
		{ "id": &"coal", "min": 1, "max": 2, "chance": 0.4 },
		{ "id": &"iron_ore", "min": 1, "max": 2, "chance": 0.25 }
	]
	
	super._ready()
