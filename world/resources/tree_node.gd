class_name TreeNode
extends ResourceNode

func _ready() -> void:
	node_name = "Oak Tree"
	node_type = NodeType.TREE
	max_health = 40.0
	required_tool_type = ItemDefinition.ToolType.AXE
	required_tool_tier = 1
	respawn_time_sec = 60.0
	
	loot_table = [
		{ "id": &"wood", "min": 3, "max": 6, "chance": 1.0 },
		{ "id": &"stick", "min": 1, "max": 3, "chance": 0.8 },
		{ "id": &"apple", "min": 1, "max": 2, "chance": 0.35 }
	]
	
	super._ready()
