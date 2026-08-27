class_name TestInteractable
extends StaticBody2D

@export var object_name: String = "Ancient Monolith"
@export var prompt_message: String = "Inspect Ancient Monolith"

var interaction_count: int = 0

func _ready() -> void:
	add_to_group("interactable")

func get_interaction_prompt() -> String:
	return "[E] " + prompt_message

func interact(player: Node2D) -> void:
	interaction_count += 1
	var msg: String = "Interacted with %s (%d times)" % [object_name, interaction_count]
	GameLogger.info("Interactable", msg)
	EventBus.notification_posted.emit("Interaction", msg, "info")
	
	# Give small trauma kick to camera for tactile feedback
	EventBus.screen_shake_requested.emit(0.25)
