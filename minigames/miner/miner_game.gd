class_name MinerGame
extends RefCounted

signal fuel_depleted()
signal cargo_full()
signal gems_sold(total_gold: int)

var fuel_liters: float = 100.0
var max_fuel_liters: float = 100.0
var current_depth_meters: int = 0
var cargo_hold: Array[String] = []
var max_cargo_slots: int = 15
var miner_gold: int = 0

func drill_down(drill_power: int = 1) -> bool:
	if fuel_liters <= 0.0:
		fuel_depleted.emit()
		return false
	
	fuel_liters = maxf(0.0, fuel_liters - 1.5)
	current_depth_meters += 5 * drill_power
	
	# Chance of striking mineral
	if randf() < 0.4 and cargo_hold.size() < max_cargo_slots:
		var gem: String = _roll_gem(current_depth_meters)
		cargo_hold.append(gem)
		if cargo_hold.size() >= max_cargo_slots:
			cargo_full.emit()
	
	return true

func _roll_gem(depth: int) -> String:
	if depth > 500:
		return "Dark Matter" if randf() < 0.2 else "Diamond"
	elif depth > 200:
		return "Ruby" if randf() < 0.4 else "Emerald"
	return "Gold Ore" if randf() < 0.5 else "Copper Ore"

func return_to_surface_and_sell() -> int:
	var value: int = 0
	for gem in cargo_hold:
		match gem:
			"Copper Ore": value += 10
			"Gold Ore": value += 30
			"Emerald": value += 60
			"Ruby": value += 100
			"Diamond": value += 200
			"Dark Matter": value += 500
	
	cargo_hold.clear()
	miner_gold += value
	fuel_liters = max_fuel_liters # Refuel
	gems_sold.emit(value)
	return value
