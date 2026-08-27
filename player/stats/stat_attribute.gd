class_name StatAttribute
extends RefCounted

signal value_changed(current: float, max_val: float)
signal depleted()
signal filled()

enum ModifierType {
	FLAT,
	PERCENT_ADDITIVE,
	PERCENT_MULTIPLICATIVE
}

class StatModifier:
	var id: String
	var value: float
	var type: ModifierType
	
	func _init(p_id: String, p_value: float, p_type: ModifierType) -> void:
		id = p_id
		value = p_value
		type = p_type

var stat_name: StringName = &"Stat"
var base_value: float = 100.0
var min_value: float = 0.0
var current_value: float = 100.0

var _modifiers: Array[StatModifier] = []
var _cached_max_value: float = 100.0
var _is_dirty: bool = true

func _init(p_name: StringName, p_base: float, p_current: float = -1.0, p_min: float = 0.0) -> void:
	stat_name = p_name
	base_value = p_base
	min_value = p_min
	_is_dirty = true
	_cached_max_value = get_max_value()
	current_value = p_current if p_current >= 0.0 else _cached_max_value

func get_max_value() -> float:
	if not _is_dirty:
		return _cached_max_value
	
	var flat_sum: float = 0.0
	var percent_add_sum: float = 0.0
	var percent_mult_product: float = 1.0
	
	for mod in _modifiers:
		match mod.type:
			ModifierType.FLAT:
				flat_sum += mod.value
			ModifierType.PERCENT_ADDITIVE:
				percent_add_sum += mod.value
			ModifierType.PERCENT_MULTIPLICATIVE:
				percent_mult_product *= (1.0 + mod.value)
	
	var calculated: float = (base_value + flat_sum) * (1.0 + percent_add_sum) * percent_mult_product
	_cached_max_value = maxf(min_value, calculated)
	_is_dirty = false
	return _cached_max_value

func get_current_value() -> float:
	return current_value

func get_ratio() -> float:
	var max_val: float = get_max_value()
	if max_val <= 0.0:
		return 0.0
	return clampf(current_value / max_val, 0.0, 1.0)

func set_current(new_val: float) -> void:
	var old_val: float = current_value
	var max_val: float = get_max_value()
	current_value = clampf(new_val, min_value, max_val)
	
	if not is_equal_approx(old_val, current_value):
		value_changed.emit(current_value, max_val)
		if current_value <= min_value:
			depleted.emit()
		elif is_equal_approx(current_value, max_val):
			filled.emit()

func modify_current(delta: float) -> void:
	set_current(current_value + delta)

func set_base_value(new_base: float) -> void:
	base_value = new_base
	_is_dirty = true
	var max_val: float = get_max_value()
	set_current(minf(current_value, max_val))

func add_modifier(id: String, val: float, type: ModifierType) -> void:
	remove_modifier(id)
	_modifiers.append(StatModifier.new(id, val, type))
	_is_dirty = true
	var max_val: float = get_max_value()
	set_current(minf(current_value, max_val))

func remove_modifier(id: String) -> void:
	for i in range(_modifiers.size() - 1, -1, -1):
		if _modifiers[i].id == id:
			_modifiers.remove_at(i)
			_is_dirty = true
	if _is_dirty:
		var max_val: float = get_max_value()
		set_current(minf(current_value, max_val))

func reset_to_max() -> void:
	set_current(get_max_value())
