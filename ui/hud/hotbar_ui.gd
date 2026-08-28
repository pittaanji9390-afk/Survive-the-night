class_name HotbarUI
extends Control

@onready var slots_container: HBoxContainer = $MarginContainer/SlotsHBox

var _player: Node2D = null
var _hotbar_manager: HotbarManager = null
var _inventory: InventoryContainer = null
var _slot_ui_nodes: Array[InventorySlotUI] = []
var _active_index: int = 0

func _ready() -> void:
	_bind_player()
	EventBus.hotbar_selection_changed.connect(_on_hotbar_selection_changed)

func _bind_player() -> void:
	_player = ServiceLocator.get_service(&"Player") as Node2D
	if not _player:
		return
	
	_inventory = _player.get_node_or_null("InventoryContainer") as InventoryContainer
	_hotbar_manager = _player.get_node_or_null("HotbarManager") as HotbarManager
	
	if _inventory and slots_container:
		_build_slots()
		_inventory.slot_updated.connect(_on_inventory_slot_updated)
		_inventory.inventory_changed.connect(refresh_hotbar)

func _build_slots() -> void:
	for child in slots_container.get_children():
		child.queue_free()
	_slot_ui_nodes.clear()
	
	var slot_scene: PackedScene = preload("res://scenes/ui/inventory_slot_ui.tscn")
	var count: int = _hotbar_manager.hotbar_size if _hotbar_manager else 8
	for i in range(count):
		var slot_ui: InventorySlotUI = slot_scene.instantiate() as InventorySlotUI
		slot_ui.slot_index = i
		slot_ui.slot_left_clicked.connect(_on_slot_clicked)
		slots_container.add_child(slot_ui)
		_slot_ui_nodes.append(slot_ui)
	
	refresh_hotbar()

func refresh_hotbar() -> void:
	if not _inventory:
		_bind_player()
	if not _inventory:
		return
	
	if _slot_ui_nodes.is_empty():
		_build_slots()
		return
	
	for i in range(_slot_ui_nodes.size()):
		if i < _inventory.slots.size():
			var slot: InventorySlot = _inventory.slots[i]
			_slot_ui_nodes[i].update_slot(slot.item_id, slot.quantity, slot.durability)
			_update_slot_highlight(i)

func _update_slot_highlight(idx: int) -> void:
	if idx < _slot_ui_nodes.size():
		if idx == _active_index:
			_slot_ui_nodes[idx].modulate = Color(1.5, 1.5, 0.6, 1.0)
		else:
			_slot_ui_nodes[idx].modulate = Color.WHITE

func _on_slot_clicked(idx: int) -> void:
	if _hotbar_manager:
		_hotbar_manager.select_slot(idx)

func _on_hotbar_selection_changed(index: int, _item_id: StringName) -> void:
	_active_index = index
	for i in range(_slot_ui_nodes.size()):
		_update_slot_highlight(i)

func _on_inventory_slot_updated(index: int, _id: StringName, _qty: int) -> void:
	if index < _slot_ui_nodes.size():
		refresh_hotbar()
