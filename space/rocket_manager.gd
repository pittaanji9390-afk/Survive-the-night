class_name RocketManager
extends Node

signal rocket_stage_completed(stage_name: String, progress_pct: float)
signal rocket_launched_to_orbit()
signal asteroid_harvested(starmetal_yield: int)

var construction_progress: float = 0.0
var is_orbital_station_unlocked: bool = false
var starmetal_inventory: int = 0

func _ready() -> void:
	ServiceLocator.register_service(&"RocketManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"RocketManager")

func contribute_materials(amount_pct: float) -> float:
	construction_progress = minf(100.0, construction_progress + amount_pct)
	rocket_stage_completed.emit("Orbital Starship", construction_progress)
	if construction_progress >= 100.0 and not is_orbital_station_unlocked:
		is_orbital_station_unlocked = true
		EventBus.notification_posted.emit("ROCKET READY FOR LAUNCH!", "All systems nominal for orbital ascent.", "rocket")
	return construction_progress

func launch_rocket() -> bool:
	if not is_orbital_station_unlocked:
		return false
	rocket_launched_to_orbit.emit()
	EventBus.notification_posted.emit("LIFTOFF!", "Ascending into deep space orbit!", "rocket")
	return true

func mine_orbital_asteroid(drill_power: int = 1) -> int:
	var yield_metal: int = 15 * drill_power
	starmetal_inventory += yield_metal
	asteroid_harvested.emit(yield_metal)
	return yield_metal
