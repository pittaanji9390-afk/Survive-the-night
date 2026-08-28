class_name FoodSpoilageManager
extends Node

signal food_spoiled(item_name: String)

@export var spoilage_check_interval_sec: float = 10.0

var _timer: float = 0.0

func _ready() -> void:
	ServiceLocator.register_service(&"FoodSpoilageManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"FoodSpoilageManager")

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= spoilage_check_interval_sec:
		_timer = 0.0
		_process_inventory_spoilage()

func _process_inventory_spoilage() -> void:
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if not player:
		return
	var inv: InventoryContainer = player.get_node_or_null("InventoryContainer") as InventoryContainer
	if not inv:
		return
	
	# Degrade raw meat durability / freshness
	for s in inv.slots:
		if not s.is_empty() and s.item_id == &"raw_meat":
			s.durability -= 0.02
			if s.durability <= 0.0:
				s.item_id = &"spoiled_matter"
				s.durability = 1.0
				s.slot_changed.emit()
				food_spoiled.emit("Raw Meat")
				EventBus.notification_posted.emit("Food Spoiled", "A piece of raw meat rotted into spoiled matter!", "warn")
