class_name EquipmentInventory
extends Node

signal equipment_changed(slot_type: int, item_id: StringName)

var equipment_slots: Dictionary = {
	ItemDefinition.EquipmentSlotType.MAIN_HAND: InventorySlot.new(),
	ItemDefinition.EquipmentSlotType.OFF_HAND: InventorySlot.new(),
	ItemDefinition.EquipmentSlotType.HEAD: InventorySlot.new(),
	ItemDefinition.EquipmentSlotType.CHEST: InventorySlot.new(),
	ItemDefinition.EquipmentSlotType.LEGS: InventorySlot.new(),
	ItemDefinition.EquipmentSlotType.FEET: InventorySlot.new(),
	ItemDefinition.EquipmentSlotType.ACCESSORY: InventorySlot.new()
}

var _player_stats: PlayerStats = null

func _ready() -> void:
	_player_stats = get_parent().get_node_or_null("PlayerStats") as PlayerStats

func equip_item(item_id: StringName, dur: int = 0) -> StringName:
	var def: ItemDefinition = ItemDatabase.get_item(item_id)
	if not def or not def.is_equipment():
		return &""
	
	var slot_type: ItemDefinition.EquipmentSlotType = def.equip_slot
	var slot: InventorySlot = equipment_slots.get(slot_type)
	if not slot:
		return &""
	
	var old_item_id: StringName = slot.item_id
	if not slot.is_empty():
		_remove_stat_modifiers(slot.get_item_definition())
	
	slot.set_item(item_id, 1, dur if dur > 0 else def.max_durability)
	_apply_stat_modifiers(def)
	
	equipment_changed.emit(int(slot_type), item_id)
	return old_item_id

func unequip_item(slot_type: ItemDefinition.EquipmentSlotType) -> StringName:
	var slot: InventorySlot = equipment_slots.get(slot_type)
	if not slot or slot.is_empty():
		return &""
	
	var removed_id: StringName = slot.item_id
	_remove_stat_modifiers(slot.get_item_definition())
	slot.clear()
	
	equipment_changed.emit(int(slot_type), &"")
	return removed_id

func get_equipped_item(slot_type: ItemDefinition.EquipmentSlotType) -> ItemDefinition:
	var slot: InventorySlot = equipment_slots.get(slot_type)
	if slot and not slot.is_empty():
		return slot.get_item_definition()
	return null

func _apply_stat_modifiers(def: ItemDefinition) -> void:
	if not _player_stats or not def:
		return
	
	var mod_id: String = "equip_" + String(def.id)
	if def.defense_bonus > 0.0:
		_player_stats.defense.add_modifier(mod_id, def.defense_bonus, StatAttribute.ModifierType.FLAT)
	if def.speed_modifier != 0.0:
		_player_stats.speed.add_modifier(mod_id, def.speed_modifier, StatAttribute.ModifierType.FLAT)
	if def.max_health_bonus > 0.0:
		_player_stats.health.add_modifier(mod_id, def.max_health_bonus, StatAttribute.ModifierType.FLAT)
	if def.base_damage > 0.0:
		_player_stats.attack_power.add_modifier(mod_id, def.base_damage, StatAttribute.ModifierType.FLAT)

func _remove_stat_modifiers(def: ItemDefinition) -> void:
	if not _player_stats or not def:
		return
	
	var mod_id: String = "equip_" + String(def.id)
	_player_stats.defense.remove_modifier(mod_id)
	_player_stats.speed.remove_modifier(mod_id)
	_player_stats.health.remove_modifier(mod_id)
	_player_stats.attack_power.remove_modifier(mod_id)
