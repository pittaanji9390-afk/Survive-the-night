class_name FluidTankStructure
extends StructureInstance

enum FluidType {
	NONE,
	WATER,
	CRUDE_OIL,
	PETROLEUM,
	SULFURIC_ACID
}

@export var max_capacity_liters: float = 500.0
@export var current_fluid_liters: float = 0.0
@export var contained_fluid_type: FluidType = FluidType.NONE

func _ready() -> void:
	structure_id = &"fluid_tank"
	super._ready()

func add_fluid(ftype: FluidType, amount: float) -> float:
	if contained_fluid_type != FluidType.NONE and contained_fluid_type != ftype and current_fluid_liters > 0.0:
		return 0.0 # Cannot mix fluids
	
	contained_fluid_type = ftype
	var space: float = max_capacity_liters - current_fluid_liters
	var added: float = minf(space, amount)
	current_fluid_liters += added
	return added

func drain_fluid(amount: float) -> float:
	var drained: float = minf(current_fluid_liters, amount)
	current_fluid_liters -= drained
	if current_fluid_liters <= 0.0:
		contained_fluid_type = FluidType.NONE
	return drained
