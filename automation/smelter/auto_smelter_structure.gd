class_name AutoSmelterStructure
extends StructureInstance

signal item_smelted(ore_id: StringName, ingot_id: StringName)

@export var smelt_interval_sec: float = 3.0
@export var ore_input_id: StringName = &"iron_ore"
@export var ingot_output_id: StringName = &"iron_ingot"

var power_comp: PowerComponent = null
var _smelt_timer: float = 0.0

var internal_ore_storage: int = 10
var internal_ingot_storage: int = 0

func _ready() -> void:
	structure_id = &"auto_smelter"
	super._ready()
	power_comp = PowerComponent.new()
	power_comp.power_type = PowerComponent.PowerType.CONSUMER
	power_comp.wattage = 30.0
	add_child(power_comp)

func _process(delta: float) -> void:
	if not power_comp or not power_comp.is_powered or internal_ore_storage <= 0:
		return
	
	_smelt_timer += delta
	if _smelt_timer >= smelt_interval_sec:
		_smelt_timer = 0.0
		internal_ore_storage -= 1
		internal_ingot_storage += 1
		item_smelted.emit(ore_input_id, ingot_output_id)
		EventBus.notification_posted.emit("Smelter", "Auto-smelted 1 x %s" % ingot_output_id, "fire")
