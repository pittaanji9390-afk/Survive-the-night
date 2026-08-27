class_name ServiceLocatorService
extends Node

var _services: Dictionary = {}

func register_service(service_name: StringName, service_instance: Object) -> void:
	if _services.has(service_name):
		GameLogger.warn("ServiceLocator", "Overwriting existing service: %s" % service_name)
	_services[service_name] = service_instance
	GameLogger.info("ServiceLocator", "Registered service: %s" % service_name)

func unregister_service(service_name: StringName) -> void:
	if _services.has(service_name):
		_services.erase(service_name)
		GameLogger.info("ServiceLocator", "Unregistered service: %s" % service_name)

func get_service(service_name: StringName) -> Object:
	if _services.has(service_name):
		return _services[service_name]
	GameLogger.warn("ServiceLocator", "Requested service '%s' not found." % service_name)
	return null

func has_service(service_name: StringName) -> bool:
	return _services.has(service_name)

func clear_all() -> void:
	_services.clear()
