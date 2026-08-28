class_name InventoryContainer
extends Node

signal slot_updated(index: int, item_id: StringName, quantity: int)
signal inventory_changed()
signal inventory_full()
signal item_added(item_id: StringName, quantity: int)
signal item_removed(item_id: StringName, quantity: int)

enum SortMode {
	BY_CATEGORY,
	BY_NAME,
	BY_RARITY,
	BY_VALUE
}

@export var max_slots: int = 24
@export var max_weight_capacity: float = 60.0

var slots: Array[InventorySlot] = []

func _init(p_slot_count: int = 24) -> void:
	max_slots = p_slot_count
	_initialize_slots()

func _ready() -> void:
	if slots.is_empty():
		_initialize_slots()

func _initialize_slots() -> void:
	slots.clear()
	for i in range(max_slots):
		var slot: InventorySlot = InventorySlot.new()
		var slot_idx: int = i
		slot.slot_changed.connect(func(): _on_slot_changed(slot_idx))
		slots.append(slot)

func add_item(id: StringName, qty: int, dur: int = 0) -> int:
	var def: ItemDefinition = ItemDatabase.get_item(id)
	if not def or qty <= 0:
		return qty
	
	var remaining: int = qty
	
	# 1. Fill existing stackable slots first
	if def.is_stackable():
		for i in range(slots.size()):
			var slot: InventorySlot = slots[i]
			if slot.can_stack_with(id):
				remaining = slot.add_quantity(remaining)
				if remaining <= 0:
					break
	
	# 2. Fill empty slots with remaining items
	if remaining > 0:
		for i in range(slots.size()):
			var slot: InventorySlot = slots[i]
			if slot.is_empty():
				var to_add: int = mini(remaining, def.max_stack) if def.is_stackable() else 1
				var item_dur: int = dur if dur > 0 else def.max_durability
				slot.set_item(id, to_add, item_dur)
				remaining -= to_add
				if remaining <= 0:
					break
	
	var added_count: int = qty - remaining
	if added_count > 0:
		item_added.emit(id, added_count)
		inventory_changed.emit()
	
	if remaining > 0:
		inventory_full.emit()
		GameLogger.info("Inventory", "Inventory full. %d x %s could not be added." % [remaining, id])
	
	return remaining

func remove_item(id: StringName, qty: int) -> bool:
	if not has_item_quantity(id, qty):
		return false
	
	var remaining: int = qty
	for i in range(slots.size() - 1, -1, -1):
		var slot: InventorySlot = slots[i]
		if slot.item_id == id:
			if slot.quantity <= remaining:
				remaining -= slot.quantity
				slot.clear()
			else:
				slot.quantity -= remaining
				remaining = 0
				slot.slot_changed.emit()
			if remaining <= 0:
				break
	
	item_removed.emit(id, qty)
	inventory_changed.emit()
	return true

func has_item_quantity(id: StringName, qty: int) -> bool:
	return get_item_count(id) >= qty

func get_item_count(id: StringName) -> int:
	var total: int = 0
	for slot in slots:
		if slot.item_id == id:
			total += slot.quantity
	return total

func swap_slots(from_idx: int, to_idx: int) -> bool:
	if not _is_valid_index(from_idx) or not _is_valid_index(to_idx) or from_idx == to_idx:
		return false
	
	var slot_a: InventorySlot = slots[from_idx]
	var slot_b: InventorySlot = slots[to_idx]
	
	# If same stackable item, merge them
	if not slot_a.is_empty() and slot_a.item_id == slot_b.item_id and slot_a.can_stack_with(slot_b.item_id):
		var remaining: int = slot_b.add_quantity(slot_a.quantity)
		if remaining == 0:
			slot_a.clear()
		else:
			slot_a.quantity = remaining
			slot_a.slot_changed.emit()
		inventory_changed.emit()
		return true
	
	# Swap contents
	var temp_id: StringName = slot_a.item_id
	var temp_qty: int = slot_a.quantity
	var temp_dur: int = slot_a.durability
	
	slot_a.set_item(slot_b.item_id, slot_b.quantity, slot_b.durability)
	slot_b.set_item(temp_id, temp_qty, temp_dur)
	
	inventory_changed.emit()
	return true

func split_slot(from_idx: int, to_idx: int, amount: int) -> bool:
	if not _is_valid_index(from_idx) or not _is_valid_index(to_idx) or from_idx == to_idx:
		return false
	
	var source: InventorySlot = slots[from_idx]
	var target: InventorySlot = slots[to_idx]
	
	if source.is_empty() or amount <= 0 or amount >= source.quantity:
		return false
	
	if target.is_empty():
		source.quantity -= amount
		target.set_item(source.item_id, amount, source.durability)
		source.slot_changed.emit()
		inventory_changed.emit()
		return true
	elif target.can_stack_with(source.item_id):
		var space: int = target.get_remaining_stack_space()
		var transfer: int = mini(amount, space)
		if transfer > 0:
			source.quantity -= transfer
			target.quantity += transfer
			source.slot_changed.emit()
			target.slot_changed.emit()
			inventory_changed.emit()
			return true
	return false

func get_total_weight() -> float:
	var total_wt: float = 0.0
	for slot in slots:
		if not slot.is_empty():
			var def: ItemDefinition = slot.get_item_definition()
			if def:
				total_wt += def.weight * float(slot.quantity)
	return total_wt

func sort_inventory(mode: SortMode = SortMode.BY_CATEGORY) -> void:
	var filled_slots: Array[InventorySlot] = []
	for slot in slots:
		if not slot.is_empty():
			filled_slots.append(slot.duplicate_slot())
	
	match mode:
		SortMode.BY_CATEGORY:
			filled_slots.sort_custom(func(a: InventorySlot, b: InventorySlot) -> bool:
				var def_a: ItemDefinition = a.get_item_definition()
				var def_b: ItemDefinition = b.get_item_definition()
				if def_a.category != def_b.category:
					return def_a.category < def_b.category
				return def_a.name < def_b.name
			)
		SortMode.BY_NAME:
			filled_slots.sort_custom(func(a: InventorySlot, b: InventorySlot) -> bool:
				return a.get_item_definition().name < b.get_item_definition().name
			)
		SortMode.BY_RARITY:
			filled_slots.sort_custom(func(a: InventorySlot, b: InventorySlot) -> bool:
				return a.get_item_definition().rarity > b.get_item_definition().rarity
			)
		SortMode.BY_VALUE:
			filled_slots.sort_custom(func(a: InventorySlot, b: InventorySlot) -> bool:
				return a.get_item_definition().value > b.get_item_definition().value
			)
	
	# Clear and repopulate
	for i in range(slots.size()):
		if i < filled_slots.size():
			var s: InventorySlot = filled_slots[i]
			slots[i].set_item(s.item_id, s.quantity, s.durability)
		else:
			slots[i].clear()
	
	inventory_changed.emit()

func serialize() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for slot in slots:
		data.append({
			"id": String(slot.item_id),
			"qty": slot.quantity,
			"dur": slot.durability
		})
	return data

func deserialize(data: Array) -> void:
	for i in range(mini(slots.size(), data.size())):
		var entry: Dictionary = data[i]
		var id: StringName = StringName(entry.get("id", ""))
		var qty: int = int(entry.get("qty", 0))
		var dur: int = int(entry.get("dur", 0))
		slots[i].set_item(id, qty, dur)
	inventory_changed.emit()

func _is_valid_index(idx: int) -> bool:
	return idx >= 0 and idx < slots.size()

func _on_slot_changed(slot_idx: int) -> void:
	var s: InventorySlot = slots[slot_idx]
	slot_updated.emit(slot_idx, s.item_id, s.quantity)
	EventBus.inventory_slot_updated.emit(slot_idx, s.item_id, s.quantity)
