class_name ResourceNode
extends StaticBody2D

signal harvested(harvester: Node2D)
signal depleted()
signal damaged(amount: float, current_hp: float, max_hp: float)

enum NodeType {
	TREE,
	ROCK,
	ORE_VEIN,
	BUSH,
	PLANT
}

@export var node_name: String = "Resource Node"
@export var node_type: NodeType = NodeType.TREE
@export var max_health: float = 50.0
@export var required_tool_type: ItemDefinition.ToolType = ItemDefinition.ToolType.NONE
@export var required_tool_tier: int = 0
@export var respawn_time_sec: float = 120.0

# Loot definition: Array of Dictionaries { "id": StringName, "min": int, "max": int, "chance": float }
@export var loot_table: Array[Dictionary] = []

var current_health: float = 50.0
var is_depleted: bool = false

var _base_scale: Vector2 = Vector2.ONE
var _tween: Tween

func _ready() -> void:
	add_to_group("resource_node")
	add_to_group("interactable")
	current_health = max_health
	var spr: Sprite2D = _get_sprite()
	if spr:
		_base_scale = spr.scale

func _get_sprite() -> Sprite2D:
	return get_node_or_null("Sprite2D") as Sprite2D

func _get_collision() -> CollisionShape2D:
	return get_node_or_null("CollisionShape2D") as CollisionShape2D

func get_interaction_prompt() -> String:
	if is_depleted:
		return "Depleted " + node_name
	var tool_hint: String = ""
	if required_tool_type == ItemDefinition.ToolType.AXE:
		tool_hint = " [Requires Axe]"
	elif required_tool_type == ItemDefinition.ToolType.PICKAXE:
		tool_hint = " [Requires Pickaxe]"
	return "[Left Click] Gather %s%s (HP: %d/%d)" % [node_name, tool_hint, int(current_health), int(max_health)]

func hit(damage: float, tool_type: ItemDefinition.ToolType, tool_tier: int, attacker: Node2D) -> float:
	if is_depleted:
		return 0.0
	
	var effective_damage: float = calculate_damage(damage, tool_type, tool_tier)
	current_health -= effective_damage
	
	_play_hit_effects()
	damaged.emit(effective_damage, current_health, max_health)
	
	EventBus.screen_shake_requested.emit(0.12)
	
	if current_health <= 0.0:
		_on_depleted(attacker)
	
	return effective_damage

func calculate_damage(raw_damage: float, tool_type: ItemDefinition.ToolType, tool_tier: int) -> float:
	if required_tool_type == ItemDefinition.ToolType.NONE:
		return maxf(5.0, raw_damage)
	
	if tool_type == required_tool_type and tool_tier >= required_tool_tier:
		var tier_multiplier: float = 1.0 + float(tool_tier - required_tool_tier) * 0.35
		return raw_damage * tier_multiplier
	
	return 1.5

func _play_hit_effects() -> void:
	var spr: Sprite2D = _get_sprite()
	if not spr:
		return
	
	if _tween and _tween.is_running():
		_tween.kill()
	
	_tween = create_tween()
	spr.modulate = Color(2.0, 2.0, 2.0, 1.0)
	_tween.tween_property(spr, "scale", _base_scale * Vector2(1.15, 0.85), 0.06)
	_tween.parallel().tween_property(spr, "modulate", Color.WHITE, 0.12)
	_tween.tween_property(spr, "scale", _base_scale, 0.08)

func _on_depleted(harvester: Node2D) -> void:
	is_depleted = true
	harvested.emit(harvester)
	depleted.emit()
	
	_spawn_loot_drops()
	
	var spr: Sprite2D = _get_sprite()
	if spr and is_inside_tree():
		var death_tween: Tween = create_tween()
		death_tween.tween_property(spr, "scale", Vector2.ZERO, 0.25)
		death_tween.tween_callback(_on_destruction_complete)
	else:
		_on_destruction_complete()

func _spawn_loot_drops() -> void:
	var drop_scene: PackedScene = preload("res://scenes/items/item_drop.tscn")
	var parent_node: Node = get_parent()
	if not parent_node or not is_inside_tree():
		return
	
	for drop_info in loot_table:
		var id: StringName = drop_info.get("id", &"")
		var min_c: int = int(drop_info.get("min", 1))
		var max_c: int = int(drop_info.get("max", 1))
		var chance: float = float(drop_info.get("chance", 1.0))
		
		if randf() <= chance:
			var count: int = randi_range(min_c, max_c)
			if count > 0:
				var drop: ItemDrop = drop_scene.instantiate() as ItemDrop
				drop.item_id = id
				drop.quantity = count
				var scatter: Vector2 = Vector2(randf_range(-20.0, 20.0), randf_range(-15.0, 15.0))
				drop.global_position = global_position + scatter
				parent_node.call_deferred("add_child", drop)

func _on_destruction_complete() -> void:
	var col: CollisionShape2D = _get_collision()
	if col:
		col.disabled = true
	visible = false
	
	if respawn_time_sec > 0.0 and is_inside_tree():
		var tree: SceneTree = get_tree()
		if tree:
			var timer: SceneTreeTimer = tree.create_timer(respawn_time_sec)
			timer.timeout.connect(respawn)
	elif not is_inside_tree():
		pass
	else:
		queue_free()

func respawn() -> void:
	is_depleted = false
	current_health = max_health
	visible = true
	var col: CollisionShape2D = _get_collision()
	if col:
		col.disabled = false
	var spr: Sprite2D = _get_sprite()
	if spr:
		spr.scale = _base_scale
		spr.modulate = Color.WHITE
	GameLogger.info("ResourceNode", "%s respawned at %v" % [node_name, global_position])
