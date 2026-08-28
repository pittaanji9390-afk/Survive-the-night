class_name ItemDrop
extends Area2D

@export var item_id: StringName = &"wood"
@export var quantity: int = 1
@export var durability: int = 0
@export var pickup_radius: float = 70.0
@export var magnet_speed: float = 240.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _target_player: Node2D = null
var _time_alive: float = 0.0
var _base_y: float = 0.0
var _can_be_picked_up: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 # Player physics layer
	
	_base_y = position.y
	body_entered.connect(_on_body_entered)
	
	_update_visuals()
	
	# Small delay before item can be magnetically pulled
	var timer: SceneTreeTimer = get_tree().create_timer(0.25)
	timer.timeout.connect(func(): _can_be_picked_up = true)

func _process(delta: float) -> void:
	_time_alive += delta
	
	# Gentle hover bobbing
	if not _target_player:
		if sprite:
			sprite.position.y = sin(_time_alive * 4.0) * 3.0
	else:
		# Magnetically fly toward player
		var dir: Vector2 = (_target_player.global_position - global_position).normalized()
		var dist: float = global_position.distance_to(_target_player.global_position)
		global_position += dir * magnet_speed * delta
		
		if dist < 18.0:
			_attempt_pickup(_target_player)

func _physics_process(_delta: float) -> void:
	if not _can_be_picked_up or _target_player:
		return
	
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if is_instance_valid(player):
		var dist_sq: float = global_position.distance_squared_to(player.global_position)
		if dist_sq <= pickup_radius * pickup_radius:
			_target_player = player

func _update_visuals() -> void:
	var def: ItemDefinition = ItemDatabase.get_item(item_id)
	if def:
		if label:
			label.text = "%s x%d" % [def.name, quantity] if quantity > 1 else def.name
			label.modulate = def.get_rarity_color()

func _on_body_entered(body: Node2D) -> void:
	if _can_be_picked_up and body.is_in_group("player"):
		_attempt_pickup(body)

func _attempt_pickup(player: Node2D) -> void:
	if not is_instance_valid(player):
		return
	
	var inv: InventoryContainer = player.get_node_or_null("InventoryContainer") as InventoryContainer
	if not inv:
		return
	
	var remaining: int = inv.add_item(item_id, quantity, durability)
	if remaining == 0:
		EventBus.item_picked_up.emit(item_id, quantity)
		queue_free()
	else:
		quantity = remaining
		_update_visuals()
		_target_player = null # Stay on ground with remaining quantity
