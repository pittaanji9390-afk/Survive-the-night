class_name DoorStructure
extends StructureInstance

var is_open: bool = false

func _ready() -> void:
	structure_id = &"wood_door"
	super._ready()

func get_interaction_prompt() -> String:
	return "[E] Close Door" if is_open else "[E] Open Door"

func interact(_player: Node2D) -> void:
	toggle_door()

func toggle_door() -> void:
	is_open = !is_open
	if collision_shape:
		collision_shape.disabled = is_open
	
	if sprite:
		var t: Tween = create_tween()
		var target_rot: float = PI * 0.45 if is_open else 0.0
		t.tween_property(sprite, "rotation", target_rot, 0.15)
	
	var msg: String = "Door Opened" if is_open else "Door Closed"
	EventBus.notification_posted.emit("Door", msg, "door")
	GameLogger.info("Building", msg)
