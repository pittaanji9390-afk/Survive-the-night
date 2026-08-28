class_name ConveyorBeltStructure
extends StructureInstance

@export var move_direction: Vector2 = Vector2.RIGHT
@export var belt_speed: float = 64.0

func _ready() -> void:
	structure_id = &"conveyor_belt"
	super._ready()

func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return
	
	var items: Array[Node] = get_tree().get_nodes_in_group("item_drop")
	for item in items:
		if is_instance_valid(item) and item is Node2D:
			var node2d: Node2D = item as Node2D
			if global_position.distance_to(node2d.global_position) <= 20.0:
				node2d.global_position += move_direction * (belt_speed * delta)
