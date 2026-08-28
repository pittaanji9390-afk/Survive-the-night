class_name BuildingMenuUI
extends Control

@onready var structure_list_vbox: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/StructureListVBox
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/TitleLabel
@onready var close_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseBtn

var _building_manager: BuildingManager = null
var _inventory: InventoryContainer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if close_btn:
		close_btn.pressed.connect(toggle_visibility)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_building"):
		toggle_visibility()

func toggle_visibility() -> void:
	if visible:
		visible = false
	else:
		_bind_systems()
		visible = true
		refresh_structures()

func _bind_systems() -> void:
	if not _building_manager:
		_building_manager = ServiceLocator.get_service(&"BuildingManager") as BuildingManager
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player and not _inventory:
		_inventory = player.get_node_or_null("InventoryContainer") as InventoryContainer

func refresh_structures() -> void:
	_bind_systems()
	if not structure_list_vbox:
		return
	
	for child in structure_list_vbox.get_children():
		child.queue_free()
	
	var all_structs: Array[StructureDefinition] = StructureDatabase.get_all_structures()
	for def in all_structs:
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(280, 40)
		
		var costs_str: Array[String] = []
		for c in def.construction_costs:
			costs_str.append("%d %s" % [c.get("count", 1), c.get("id", "")])
		
		var can_afford: bool = def.can_build(_inventory)
		btn.text = "%s (HP: %d) | Cost: %s" % [def.display_name, int(def.max_health), ", ".join(costs_str)]
		btn.modulate = Color.WHITE if can_afford else Color(0.65, 0.65, 0.65, 0.75)
		
		var struct_id: StringName = def.structure_id
		btn.pressed.connect(func(): _select_and_build(struct_id))
		structure_list_vbox.add_child(btn)

func _select_and_build(id: StringName) -> void:
	if _building_manager:
		_building_manager.select_structure(id)
	visible = false
