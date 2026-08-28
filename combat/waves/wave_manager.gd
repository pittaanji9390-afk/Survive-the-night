class_name WaveManager
extends Node

signal wave_threat_updated(current_threat: int)
signal blood_moon_started(night_num: int)

@export var base_wave_threat: int = 10
@export var threat_growth_per_day: int = 5

var current_threat_budget: int = 10
var is_blood_moon: bool = false

func _ready() -> void:
	ServiceLocator.register_service(&"WaveManager", self)
	EventBus.night_started.connect(_on_night_started)
	EventBus.day_started.connect(_on_day_started)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"WaveManager")

func calculate_threat_budget(day: int) -> int:
	var threat: int = base_wave_threat + (day * threat_growth_per_day)
	if day % 5 == 0:
		threat *= 2 # Blood Moon double threat
	return threat

func _on_night_started(night_num: int) -> void:
	current_threat_budget = calculate_threat_budget(night_num)
	is_blood_moon = (night_num % 5 == 0)
	
	if is_blood_moon:
		blood_moon_started.emit(night_num)
		EventBus.notification_posted.emit("BLOOD MOON RISES", "A crimson eclipse enrages all nocturnal horrors!", "danger")
		EventBus.screen_shake_requested.emit(0.3)
	
	wave_threat_updated.emit(current_threat_budget)
	GameLogger.info("WaveManager", "Night %d started. Threat Budget: %d (Blood Moon: %s)" % [night_num, current_threat_budget, is_blood_moon])

func _on_day_started(_day_num: int) -> void:
	is_blood_moon = false
