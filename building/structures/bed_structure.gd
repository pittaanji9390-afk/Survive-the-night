class_name BedStructure
extends StructureInstance

func _ready() -> void:
	structure_id = &"simple_bed"
	super._ready()

func get_interaction_prompt() -> String:
	if TimeManager.is_night():
		return "[E] Sleep until Morning (06:00)"
	return "Bed (Can only sleep during night)"

func interact(player: Node2D) -> void:
	if not TimeManager.is_night():
		EventBus.notification_posted.emit("Rest", "You can only sleep when darkness falls.", "bed")
		return
	
	GameLogger.info("Building", "Player is resting in bed...")
	EventBus.notification_posted.emit("Rest", "Sleeping... Awoke at dawn!", "bed")
	
	# Skip to morning 06:00 AM next day
	TimeManager.set_time(6.0)
	
	# Fully heal player
	var p_ctrl: PlayerController = player as PlayerController
	if p_ctrl and p_ctrl.stats:
		p_ctrl.stats.heal(100.0)
		p_ctrl.stats.stamina.reset_to_max()
