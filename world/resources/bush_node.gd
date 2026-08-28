class_name BushNode
extends ResourceNode

func _ready() -> void:
	node_name = "Berry Bush"
	node_type = NodeType.BUSH
	max_health = 15.0
	required_tool_type = ItemDefinition.ToolType.NONE
	required_tool_tier = 0
	respawn_time_sec = 45.0
	
	loot_table = [
		{ "id": &"berries", "min": 2, "max": 4, "chance": 1.0 },
		{ "id": &"fiber", "min": 1, "max": 3, "chance": 0.85 }
	]
	
	super._ready()
