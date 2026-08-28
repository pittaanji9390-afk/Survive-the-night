class_name ChestStructure
extends StructureInstance

var container: InventoryContainer = null

func _ready() -> void:
	structure_id = &"wood_chest"
	super._ready()
	container = get_node_or_null("InventoryContainer") as InventoryContainer
	if not container:
		container = InventoryContainer.new(16)
		container.name = "InventoryContainer"
		add_child(container)

func get_interaction_prompt() -> String:
	return "[E] Open Storage Chest"

func interact(player: Node2D) -> void:
	if not player or not is_inside_tree():
		return
	var canvas: CanvasLayer = player.get_tree().root.find_child("CanvasLayer", true, false) as CanvasLayer
	if canvas:
		var chest_ui: ChestUI = canvas.get_node_or_null("ChestUI") as ChestUI
		if chest_ui:
			chest_ui.open_chest(container)
			EventBus.notification_posted.emit("Storage", "Opened Wooden Chest", "chest")
