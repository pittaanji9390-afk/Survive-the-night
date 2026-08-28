class_name CraftingStation
extends StaticBody2D

@export var station_name: String = "Crafting Station"
@export var station_type: CraftingRecipe.StationType = CraftingRecipe.StationType.WORKBENCH

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("crafting_station")

func get_interaction_prompt() -> String:
	return "[E] Use %s" % station_name

func interact(player: Node2D) -> void:
	var canvas: CanvasLayer = player.get_tree().root.find_child("CanvasLayer", true, false) as CanvasLayer
	if canvas:
		var craft_ui: CraftingUI = canvas.get_node_or_null("CraftingUI") as CraftingUI
		if craft_ui:
			craft_ui.current_station = station_type
			craft_ui.toggle_visibility()
			EventBus.notification_posted.emit("Crafting Station", "Opened " + station_name, "craft")
