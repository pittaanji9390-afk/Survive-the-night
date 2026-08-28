class_name StructureInstance
extends StaticBody2D

signal structure_damaged(amount: float, cur_hp: float, max_hp: float)
signal structure_repaired(cur_hp: float, max_hp: float)
signal structure_destroyed()

@export var structure_id: StringName = &"wood_wall"
@export var grid_coords: Vector2i = Vector2i.ZERO

var current_health: float = 100.0
var max_health: float = 100.0
var armor: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D

var _base_scale: Vector2 = Vector2.ONE
var _tween: Tween

func _ready() -> void:
	add_to_group("structure")
	add_to_group("interactable")
	_apply_definition()
	if sprite:
		_base_scale = sprite.scale

func _apply_definition() -> void:
	var def: StructureDefinition = StructureDatabase.get_structure(structure_id)
	if def:
		max_health = def.max_health
		current_health = max_health
		armor = def.armor
		if def.is_passable and collision_shape:
			collision_shape.disabled = true

func get_interaction_prompt() -> String:
	var def: StructureDefinition = StructureDatabase.get_structure(structure_id)
	var title: String = def.display_name if def else String(structure_id)
	if current_health < max_health:
		return "[E] Repair %s (%d/%d HP)" % [title, int(current_health), int(max_health)]
	return title + " (Intact)"

func take_damage(amount: float, attacker: Node2D = null) -> float:
	var effective: float = maxf(1.0, amount - armor)
	current_health = maxf(0.0, current_health - effective)
	
	_play_hit_effects()
	structure_damaged.emit(effective, current_health, max_health)
	
	if current_health <= 0.0:
		destroy(attacker)
	
	return effective

func repair(amount: float, inventory: InventoryContainer = null) -> bool:
	if current_health >= max_health:
		return false
	
	current_health = minf(max_health, current_health + amount)
	structure_repaired.emit(current_health, max_health)
	
	if sprite:
		var t: Tween = create_tween()
		sprite.modulate = Color(0.4, 1.4, 0.6, 1.0)
		t.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	return true

func deconstruct(inventory: InventoryContainer = null) -> void:
	var def: StructureDefinition = StructureDatabase.get_structure(structure_id)
	if def and inventory:
		def.refund_costs(inventory)
	destroy()

func destroy(_killer: Node2D = null) -> void:
	structure_destroyed.emit()
	EventBus.structure_destroyed.emit(self)
	
	# Spawn small debris shake
	EventBus.screen_shake_requested.emit(0.15)
	
	if is_inside_tree() and sprite:
		var death_tween: Tween = create_tween()
		death_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
		death_tween.tween_callback(queue_free)
	else:
		queue_free()

func _play_hit_effects() -> void:
	if not sprite:
		return
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	sprite.modulate = Color(1.8, 0.5, 0.5, 1.0)
	_tween.tween_property(sprite, "scale", _base_scale * Vector2(1.1, 0.9), 0.05)
	_tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.1)
	_tween.tween_property(sprite, "scale", _base_scale, 0.06)
