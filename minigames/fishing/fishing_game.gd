class_name FishingGame
extends RefCounted

signal fish_hooked(fish_name: String, weight_kg: float)
signal line_snapped()
signal fish_caught(fish_name: String, score: int)

enum FishingState {
	CASTING,
	WAITING_FOR_BITE,
	REELING_FIGHT,
	CAUGHT,
	FAILED
}

var current_state: FishingState = FishingState.CASTING
var line_tension: float = 0.5 # 0.0 to 1.0 (Sweet spot: 0.4 to 0.7)
var distance_to_boat: float = 50.0 # meters
var fish_stamina: float = 100.0
var hooked_fish_name: String = "Rainbow Trout"
var hooked_fish_value: int = 150

func hook_fish(fish_name: String, initial_dist: float = 50.0, value: int = 150) -> void:
	hooked_fish_name = fish_name
	distance_to_boat = initial_dist
	fish_stamina = 100.0
	line_tension = 0.5
	hooked_fish_value = value
	current_state = FishingState.REELING_FIGHT
	fish_hooked.emit(hooked_fish_name, initial_dist)

func update_reel(delta: float, is_reeling: bool) -> void:
	if current_state != FishingState.REELING_FIGHT:
		return
	
	if is_reeling:
		line_tension = minf(1.1, line_tension + 0.35 * delta)
		if line_tension >= 0.4 and line_tension <= 0.75:
			# Sweet spot: reel in distance
			distance_to_boat = maxf(0.0, distance_to_boat - 12.0 * delta)
			fish_stamina = maxf(0.0, fish_stamina - 15.0 * delta)
	else:
		line_tension = maxf(0.0, line_tension - 0.25 * delta)
	
	if line_tension >= 1.0:
		current_state = FishingState.FAILED
		line_snapped.emit()
	elif distance_to_boat <= 0.0:
		current_state = FishingState.CAUGHT
		fish_caught.emit(hooked_fish_name, hooked_fish_value)
