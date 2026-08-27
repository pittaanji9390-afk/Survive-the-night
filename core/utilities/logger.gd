class_name GameLogger
extends RefCounted

enum Level { DEBUG, INFO, WARN, ERROR }

static var current_level: Level = Level.DEBUG

static func _format(category: String, message: String, level_name: String) -> String:
	var time_str: String = Time.get_time_string_from_system()
	return "[%s] [%s] [%s] %s" % [time_str, level_name, category.to_upper(), message]

static func debug(category: String, message: String) -> void:
	if current_level <= Level.DEBUG:
		print(_format(category, message, "DEBUG"))

static func info(category: String, message: String) -> void:
	if current_level <= Level.INFO:
		print(_format(category, message, "INFO"))

static func warn(category: String, message: String) -> void:
	if current_level <= Level.WARN:
		push_warning(_format(category, message, "WARN"))

static func error(category: String, message: String) -> void:
	if current_level <= Level.ERROR:
		push_error(_format(category, message, "ERROR"))
