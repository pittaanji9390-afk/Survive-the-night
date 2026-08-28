class_name HotbarManager
extends Node

signal active_slot_changed(slot_index: int, item_id: StringName)

@export var hotbar_size: int = 8
var active_index: int = 0

var _inventory: InventoryContainer = null

func _ready() -> void:
	_inventory = get_parent().get_node_or_null("InventoryContainer") as InventoryContainer
	if _inventory:
		_inventory.slot_updated.connect(_on_inventory_slot_updated)
	
	_notify_active_slot_changed()

func _unhandled_input(event: InputEvent) -> void:
	if not GameStateManager.is_gameplay_active():
		return
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key: int = event.keycode
		if key >= KEY_1 and key <= KEY_8:
			select_slot(key - KEY_1)
	
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_slot((active_index - 1 + hotbar_size) % hotbar_size)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_slot((active_index + 1) % hotbar_size)

func select_slot(index: int) -> void:
	if index < 0 or index >= hotbar_size or index == active_index:
		return
	active_index = index
	_notify_active_slot_changed()

func get_active_slot() -> InventorySlot:
	if _inventory and active_index < _inventory.slots.size():
		return _inventory.slots[active_index]
	return null

func get_active_item() -> ItemDefinition:
	var slot: InventorySlot = get_active_slot()
	if slot and not slot.is_empty():
		return slot.get_item_definition()
	return null

func _notify_active_slot_changed() -> void:
	var item_id: StringName = &""
	var slot: InventorySlot = get_active_slot()
	if slot and not slot.is_empty():
		item_id = slot.item_id
	
	active_slot_changed.emit(active_index, item_id)
	EventBus.hotbar_selection_changed.emit(active_index, item_id)

func _on_inventory_slot_updated(index: int, item_id: StringName, _quantity: int) -> void:
	if index == active_index:
		_notify_active_slot_changed()
