class_name NPCEntity
extends StaticBody2D

@export var npc_id: StringName = &"npc_elder"

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("npc")

func get_interaction_prompt() -> String:
	var def: NPCDefinition = NPCDatabase.get_npc(npc_id)
	var title: String = def.npc_name if def else String(npc_id)
	return "[E] Speak with %s" % title

func interact(player: Node2D) -> void:
	var def: NPCDefinition = NPCDatabase.get_npc(npc_id)
	if not def:
		return
	
	var canvas: CanvasLayer = player.get_tree().root.find_child("CanvasLayer", true, false) as CanvasLayer
	if canvas:
		var diag_ui: DialogueUI = canvas.get_node_or_null("DialogueUI") as DialogueUI
		if diag_ui:
			diag_ui.open_dialogue(def)
			EventBus.dialogue_started.emit(npc_id)
