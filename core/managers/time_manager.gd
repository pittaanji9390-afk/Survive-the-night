class_name TimeManagerService
extends Node

enum DayPhase {
	MORNING,
	DAY,
	SUNSET,
	NIGHT
}

@export var time_scale: float = 1.0
@export var is_time_paused: bool = false

var current_day: int = 1
var current_hour: float = 8.0 # 0.0 to 24.0
var current_minute: int = 0
var current_phase: DayPhase = DayPhase.MORNING

# Daylight factor from 0.0 (pitch black night) to 1.0 (bright noon)
var daylight_factor: float = 1.0

var _total_elapsed_game_seconds: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	current_hour = GameConfig.DEFAULT_START_HOUR
	_update_phase(true)

func _process(delta: float) -> void:
	if is_time_paused:
		return
	
	var day_duration: float = GameConfig.SECONDS_PER_GAME_DAY
	var game_hours_per_real_sec: float = 24.0 / day_duration
	var hours_to_add: float = delta * game_hours_per_real_sec * time_scale
	
	advance_time(hours_to_add)

func advance_time(hours: float) -> void:
	var prev_hour: int = int(floor(current_hour))
	var prev_min: int = current_minute
	
	current_hour += hours
	_total_elapsed_game_seconds += hours * 3600.0
	
	if current_hour >= 24.0:
		current_hour -= 24.0
		current_day += 1
		GameLogger.info("TimeManager", "New Day %d started!" % current_day)
		EventBus.day_started.emit(current_day)
	
	var new_hour: int = int(floor(current_hour))
	current_minute = int((current_hour - float(new_hour)) * 60.0)
	
	_update_daylight()
	_update_phase(false)
	
	if prev_hour != new_hour or prev_min != current_minute:
		EventBus.time_tick.emit(new_hour, current_minute)

func set_time(hour: float) -> void:
	current_hour = clampf(hour, 0.0, 23.99)
	current_minute = int((current_hour - floor(current_hour)) * 60.0)
	_update_daylight()
	_update_phase(true)
	EventBus.time_tick.emit(int(floor(current_hour)), current_minute)

func set_day(day: int) -> void:
	current_day = maxi(1, day)
	EventBus.day_started.emit(current_day)

func is_night() -> bool:
	return current_phase == DayPhase.NIGHT

func get_time_string() -> String:
	var h: int = int(floor(current_hour))
	var m: int = current_minute
	return "%02d:%02d" % [h, m]

func get_phase_name() -> String:
	match current_phase:
		DayPhase.MORNING: return "Morning"
		DayPhase.DAY: return "Day"
		DayPhase.SUNSET: return "Sunset"
		DayPhase.NIGHT: return "Night"
	return "Day"

func _update_phase(force_signal: bool) -> void:
	var old_phase: DayPhase = current_phase
	var h: float = current_hour
	
	if h >= 6.0 and h < 12.0:
		current_phase = DayPhase.MORNING
	elif h >= 12.0 and h < 18.0:
		current_phase = DayPhase.DAY
	elif h >= 18.0 and h < 20.5:
		current_phase = DayPhase.SUNSET
	else:
		current_phase = DayPhase.NIGHT
	
	if old_phase != current_phase or force_signal:
		EventBus.day_phase_changed.emit(int(current_phase))
		if current_phase == DayPhase.NIGHT and (old_phase != DayPhase.NIGHT or force_signal):
			EventBus.night_started.emit(current_day)

func _update_daylight() -> void:
	# Peak at noon (12:00 = 1.0), pitch black at midnight (0:00 = 0.05)
	# Sinusoidal curve between sunrise (6am) and sunset (8pm)
	var h: float = current_hour
	if h >= 5.0 and h <= 21.0:
		# Map 5.0 -> 0.0, 13.0 -> 1.0, 21.0 -> 0.0
		var normalized: float = (h - 5.0) / 16.0 # 0.0 to 1.0
		var sin_factor: float = sin(normalized * PI)
		daylight_factor = clampf(sin_factor, 0.05, 1.0)
	else:
		daylight_factor = 0.05
