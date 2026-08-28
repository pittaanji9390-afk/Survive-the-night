class_name PowerComponent
extends Node

enum PowerType {
	PRODUCER,
	CONSUMER,
	STORAGE
}

@export var power_type: PowerType = PowerType.CONSUMER
@export var wattage: float = 20.0 # Generation if PRODUCER, consumption if CONSUMER
@export var max_storage_capacity: float = 1000.0 # Joules if STORAGE
@export var current_stored_joules: float = 0.0
@export var is_active: bool = true

var is_powered: bool = true

func _ready() -> void:
	var mgr: PowerGridManager = ServiceLocator.get_service(&"PowerGridManager") as PowerGridManager
	if mgr:
		mgr.register_component(self)

func _exit_tree() -> void:
	var mgr: PowerGridManager = ServiceLocator.get_service(&"PowerGridManager") as PowerGridManager
	if mgr:
		mgr.unregister_component(self)
