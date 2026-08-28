class_name PowerGridManager
extends Node

signal grid_updated(generation_watts: float, demand_watts: float, stored_joules: float, capacity_joules: float)
signal grid_blackout_started()
signal grid_blackout_resolved()

var _producers: Array[PowerComponent] = []
var _consumers: Array[PowerComponent] = []
var _batteries: Array[PowerComponent] = []

var total_generation: float = 0.0
var total_demand: float = 0.0
var total_stored_joules: float = 0.0
var total_storage_capacity: float = 0.0
var is_in_blackout: bool = false

func _ready() -> void:
	ServiceLocator.register_service(&"PowerGridManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"PowerGridManager")

func register_component(comp: PowerComponent) -> void:
	match comp.power_type:
		PowerComponent.PowerType.PRODUCER:
			if not _producers.has(comp): _producers.append(comp)
		PowerComponent.PowerType.CONSUMER:
			if not _consumers.has(comp): _consumers.append(comp)
		PowerComponent.PowerType.STORAGE:
			if not _batteries.has(comp): _batteries.append(comp)

func unregister_component(comp: PowerComponent) -> void:
	_producers.erase(comp)
	_consumers.erase(comp)
	_batteries.erase(comp)

func _process(delta: float) -> void:
	update_power_tick(delta)

func update_power_tick(delta: float) -> void:
	total_generation = 0.0
	total_demand = 0.0
	total_stored_joules = 0.0
	total_storage_capacity = 0.0
	
	# Sum generation
	for p in _producers:
		if p.is_active:
			total_generation += p.wattage
	
	# Sum demand
	for c in _consumers:
		if c.is_active:
			total_demand += c.wattage
	
	# Sum battery capacities
	for b in _batteries:
		total_stored_joules += b.current_stored_joules
		total_storage_capacity += b.max_storage_capacity
	
	var net_watts: float = total_generation - total_demand
	
	if net_watts >= 0.0:
		# Surplus power: charge batteries
		var surplus_joules: float = net_watts * delta
		_charge_batteries(surplus_joules)
		_set_consumers_powered(true)
		if is_in_blackout:
			is_in_blackout = false
			grid_blackout_resolved.emit()
	else:
		# Deficit: discharge batteries
		var deficit_joules: float = absf(net_watts) * delta
		if total_stored_joules >= deficit_joules:
			_discharge_batteries(deficit_joules)
			_set_consumers_powered(true)
			if is_in_blackout:
				is_in_blackout = false
				grid_blackout_resolved.emit()
		else:
			# Blackout! Batteries dead
			_discharge_batteries(total_stored_joules)
			_set_consumers_powered(false)
			if not is_in_blackout:
				is_in_blackout = true
				grid_blackout_started.emit()
	
	grid_updated.emit(total_generation, total_demand, total_stored_joules, total_storage_capacity)

func _charge_batteries(amount_joules: float) -> void:
	var remaining: float = amount_joules
	for b in _batteries:
		var space: float = b.max_storage_capacity - b.current_stored_joules
		if space > 0.0:
			var add: float = minf(space, remaining)
			b.current_stored_joules += add
			remaining -= add
			if remaining <= 0.0:
				break

func _discharge_batteries(amount_joules: float) -> void:
	var remaining: float = amount_joules
	for b in _batteries:
		if b.current_stored_joules > 0.0:
			var take: float = minf(b.current_stored_joules, remaining)
			b.current_stored_joules -= take
			remaining -= take
			if remaining <= 0.0:
				break

func _set_consumers_powered(powered: bool) -> void:
	for c in _consumers:
		c.is_powered = powered
