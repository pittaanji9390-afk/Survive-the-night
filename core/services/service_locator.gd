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
	if not _services.has(service_name):
		GameLogger.warn("ServiceLocator", "Requested service '%s' not found." % service_name)
		return null
	
	if not is_instance_valid(_services[service_name]):
		_services.erase(service_name)
		GameLogger.warn("ServiceLocator", "Requested service '%s' was previously freed." % service_name)
		return null
	
	return _services[service_name]

func has_service(service_name: StringName) -> bool:
	if _services.has(service_name):
		if is_instance_valid(_services[service_name]):
			return true
		_services.erase(service_name)
	return false

func clear_all() -> void:
	_services.clear()
