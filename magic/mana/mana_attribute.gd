class_name ManaAttribute
extends RefCounted

signal mana_changed(current: float, max_val: float)
signal mana_depleted()

var base_mana: float = 100.0
var current_mana: float = 100.0
var mana_regen_rate: float = 8.0 # MP per second

func update_mana(delta: float) -> void:
	if current_mana < base_mana:
		current_mana = minf(base_mana, current_mana + mana_regen_rate * delta)
		mana_changed.emit(current_mana, base_mana)

func spend_mana(amount: float) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		mana_changed.emit(current_mana, base_mana)
		if current_mana <= 0.0:
			mana_depleted.emit()
		return true
	return false

func restore_mana(amount: float) -> void:
	current_mana = minf(base_mana, current_mana + amount)
	mana_changed.emit(current_mana, base_mana)
