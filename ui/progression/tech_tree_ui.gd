class_name TechTreeUI
extends Control

@onready var points_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/PointsLabel
@onready var tech_list_vbox: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/TechListVBox
@onready var tech_title: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DetailsVBox/TechTitle
@onready var tech_desc: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DetailsVBox/TechDesc
@onready var prereq_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DetailsVBox/PrereqLabel
@onready var cost_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DetailsVBox/CostLabel
@onready var unlock_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DetailsVBox/UnlockBtn
@onready var close_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseBtn

var _tech_tree: TechTreeManager = null
var _inventory: InventoryContainer = null
var _selected_tech_id: StringName = &""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if unlock_btn:
		unlock_btn.pressed.connect(_on_unlock_pressed)
	if close_btn:
		close_btn.pressed.connect(toggle_visibility)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_T or event.keycode == KEY_K:
			toggle_visibility()

func toggle_visibility() -> void:
	if visible:
		visible = false
		if GameStateManager.is_state(GameStateManagerService.GameState.DIALOGUE):
			GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	else:
		_bind_systems()
		visible = true
		refresh_ui()

func _bind_systems() -> void:
	if not _tech_tree:
		_tech_tree = ServiceLocator.get_service(&"TechTree") as TechTreeManager
		if _tech_tree:
			_tech_tree.tech_unlocked.connect(func(_id): refresh_ui())
			_tech_tree.research_points_changed.connect(func(_pts): refresh_ui())
	
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player and not _inventory:
		_inventory = player.get_node_or_null("InventoryContainer") as InventoryContainer

func refresh_ui() -> void:
	_bind_systems()
	if not _tech_tree:
		return
	
	if points_label:
		points_label.text = "Research Science Points: %d" % _tech_tree.available_research_points
	
	if not tech_list_vbox:
		return
	
	for child in tech_list_vbox.get_children():
		child.queue_free()
	
	var all_techs: Array[TechNode] = _tech_tree.get_all_techs()
	for node in all_techs:
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(220, 36)
		
		var is_unlocked: bool = _tech_tree.is_tech_unlocked(node.tech_id)
		var can_unlock: bool = _tech_tree.can_unlock_tech(node.tech_id, _inventory)
		
		var status_str: String = "[RESEARCHED]" if is_unlocked else ("[AVAILABLE]" if can_unlock else "[LOCKED]")
		btn.text = "%s %s (Cost: %d)" % [status_str, node.title, node.cost_research_points]
		
		if is_unlocked:
			btn.modulate = Color(0.4, 0.95, 0.5, 1.0)
		elif can_unlock:
			btn.modulate = Color(1.0, 0.9, 0.3, 1.0)
		else:
			btn.modulate = Color(0.6, 0.6, 0.6, 0.7)
		
		var t_id: StringName = node.tech_id
		btn.pressed.connect(func(): _select_tech(t_id))
		tech_list_vbox.add_child(btn)
	
	if _selected_tech_id == &"" and not all_techs.is_empty():
		_selected_tech_id = all_techs[0].tech_id
	
	_update_details()

func _select_tech(id: StringName) -> void:
	_selected_tech_id = id
	_update_details()

func _update_details() -> void:
	if not _tech_tree or _selected_tech_id == &"":
		return
	
	var node: TechNode = _tech_tree.get_tech(_selected_tech_id)
	if not node:
		return
	
	if tech_title:
		tech_title.text = node.title
	if tech_desc:
		tech_desc.text = node.description
	
	if prereq_label:
		if node.prerequisites.is_empty():
			prereq_label.text = "Prerequisites: None"
		else:
			var prereq_names: Array[String] = []
			for p in node.prerequisites:
				var p_node: TechNode = _tech_tree.get_tech(p)
				prereq_names.append(p_node.title if p_node else String(p))
			prereq_label.text = "Prerequisites: " + ", ".join(prereq_names)
	
	if cost_label:
		var cost_str: String = "Science Cost: %d Points" % node.cost_research_points
		if not node.material_costs.is_empty():
			var mats: Array[String] = []
			for m in node.material_costs:
				mats.append("%d x %s" % [m.get("count", 1), m.get("id", "")])
			cost_str += " | Materials: " + ", ".join(mats)
		cost_label.text = cost_str
	
	if unlock_btn:
		var is_unlocked: bool = _tech_tree.is_tech_unlocked(node.tech_id)
		var can_unlock: bool = _tech_tree.can_unlock_tech(node.tech_id, _inventory)
		
		if is_unlocked:
			unlock_btn.text = "Already Researched"
			unlock_btn.disabled = true
		elif can_unlock:
			unlock_btn.text = "Research Technology"
			unlock_btn.disabled = false
		else:
			unlock_btn.text = "Requirements Not Met"
			unlock_btn.disabled = true

func _on_unlock_pressed() -> void:
	if not _tech_tree or _selected_tech_id == &"":
		return
	_tech_tree.unlock_tech(_selected_tech_id, _inventory)
	refresh_ui()
