class_name SeasonManager
extends Node

signal season_changed(new_season: SeasonType, season_name: String)

enum SeasonType {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER
}

@export var days_per_season: int = 5
var current_season: SeasonType = SeasonType.SPRING

func _ready() -> void:
	ServiceLocator.register_service(&"SeasonManager", self)
	EventBus.day_started.connect(_on_day_started)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"SeasonManager")

func _on_day_started(day_number: int) -> void:
	var season_idx: int = int((day_number - 1) / days_per_season) % 4
	var old_season: SeasonType = current_season
	current_season = season_idx as SeasonType
	
	if current_season != old_season:
		var s_name: String = get_season_name(current_season)
		season_changed.emit(current_season, s_name)
		EventBus.notification_posted.emit("SEASON CHANGED", "A new season has begun: %s!" % s_name, "season")
		GameLogger.info("SeasonManager", "Season changed to: %s" % s_name)

func get_season_name(season: SeasonType) -> String:
	match season:
		SeasonType.SPRING: return "Spring"
		SeasonType.SUMMER: return "Summer"
		SeasonType.AUTUMN: return "Autumn"
		SeasonType.WINTER: return "Winter"
	return "Unknown"

func get_temperature_modifier() -> float:
	match current_season:
		SeasonType.SPRING: return 0.0
		SeasonType.SUMMER: return 8.0 # Hot
		SeasonType.AUTUMN: return -3.0
		SeasonType.WINTER: return -12.0 # Freezing cold
	return 0.0
