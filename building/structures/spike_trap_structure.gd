class_name SpikeTrapStructure
extends StructureInstance

@export var trap_damage: float = 30.0
@export var max_triggers: int = 5

var current_triggers: int = 0
var _trap_sensor: Area2D = null

func _ready() -> void:
	structure_id = &"spike_trap"
	super._ready()
	_trap_sensor = get_node_or_null("Area2D") as Area2D
	if _trap_sensor:
		_trap_sensor.body_entered.connect(_on_body_stepped)

func _on_body_stepped(body: Node2D) -> void:
	if body == self or body.is_in_group("player"):
		return
	
	if body.has_method("take_damage"):
		body.take_damage(trap_damage, self)
	
	current_triggers += 1
	_play_hit_effects()
	EventBus.screen_shake_requested.emit(0.1)
	
	if current_triggers >= max_triggers:
		destroy()
