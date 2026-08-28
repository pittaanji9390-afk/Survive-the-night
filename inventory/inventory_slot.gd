class_name InventorySlot
extends RefCounted

signal slot_changed()

var item_id: StringName = &""
var quantity: int = 0
var durability: int = 0

func _init(p_id: StringName = &"", p_qty: int = 0, p_dur: int = 0) -> void:
	item_id = p_id
	quantity = p_qty
	durability = p_dur

func is_empty() -> bool:
	return item_id == &"" or quantity <= 0

func get_item_definition() -> ItemDefinition:
	if is_empty():
		return null
	return ItemDatabase.get_item(item_id)

func can_stack_with(other_id: StringName) -> bool:
	if is_empty() or item_id != other_id:
		return false
	var def: ItemDefinition = get_item_definition()
	if not def or not def.is_stackable():
		return false
	return quantity < def.max_stack

func get_remaining_stack_space() -> int:
	if is_empty():
		return 9999
	var def: ItemDefinition = get_item_definition()
	if not def or not def.is_stackable():
		return 0
	return maxi(0, def.max_stack - quantity)

func add_quantity(amount: int) -> int:
	var def: ItemDefinition = get_item_definition()
	if not def or not def.is_stackable():
		return amount
	var space: int = def.max_stack - quantity
	var added: int = mini(amount, space)
	quantity += added
	slot_changed.emit()
	return amount - added

func set_item(p_id: StringName, p_qty: int, p_dur: int = 0) -> void:
	item_id = p_id
	quantity = p_qty
	durability = p_dur
	if quantity <= 0 or item_id == &"":
		clear()
	else:
		slot_changed.emit()

func clear() -> void:
	item_id = &""
	quantity = 0
	durability = 0
	slot_changed.emit()

func split(amount: int) -> InventorySlot:
	if is_empty() or amount <= 0 or amount >= quantity:
		return null
	quantity -= amount
	slot_changed.emit()
	return InventorySlot.new(item_id, amount, durability)

func duplicate_slot() -> InventorySlot:
	return InventorySlot.new(item_id, quantity, durability)
