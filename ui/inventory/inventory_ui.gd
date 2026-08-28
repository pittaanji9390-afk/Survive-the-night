class_name InventoryUI
extends Control

@onready var grid_container: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var weight_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/WeightLabel
@onready var weight_bar: ProgressBar = $PanelContainer/MarginContainer/VBoxContainer/WeightBar
@onready var sort_category_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/SortCategoryBtn
@onready var sort_name_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/SortNameBtn
@onready var sort_rarity_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/SortRarityBtn
@onready var drop_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/DropBtn
@onready var close_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseBtn

var _inventory: InventoryContainer = null
var _slot_ui_nodes: Array[InventorySlotUI] = []
var _selected_slot_idx: int = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if sort_category_btn:
		sort_category_btn.pressed.connect(func(): _sort_inventory(InventoryContainer.SortMode.BY_CATEGORY))
	if sort_name_btn:
		sort_name_btn.pressed.connect(func(): _sort_inventory(InventoryContainer.SortMode.BY_NAME))
	if sort_rarity_btn:
		sort_rarity_btn.pressed.connect(func(): _sort_inventory(InventoryContainer.SortMode.BY_RARITY))
	if drop_btn:
		drop_btn.pressed.connect(_drop_selected_item)
	if close_btn:
		close_btn.pressed.connect(toggle_visibility)
	
	EventBus.game_state_changed.connect(_on_game_state_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle_visibility()

func toggle_visibility() -> void:
	if visible:
		visible = false
		_selected_slot_idx = -1
		if GameStateManager.is_state(GameStateManagerService.GameState.INVENTORY):
			GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	else:
		_bind_inventory()
		visible = true
		_selected_slot_idx = -1
		refresh_ui()
		GameStateManager.change_state(GameStateManagerService.GameState.INVENTORY)

func _bind_inventory() -> void:
	if _inventory:
		return
	
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player:
		_inventory = player.get_node_or_null("InventoryContainer") as InventoryContainer
		if _inventory:
			_inventory.inventory_changed.connect(refresh_ui)
			_build_grid_slots()

func _build_grid_slots() -> void:
	if not grid_container or not _inventory:
		return
	
	for child in grid_container.get_children():
		child.queue_free()
	_slot_ui_nodes.clear()
	
	var slot_scene: PackedScene = preload("res://scenes/ui/inventory_slot_ui.tscn")
	for i in range(_inventory.slots.size()):
		var slot_ui: InventorySlotUI = slot_scene.instantiate() as InventorySlotUI
		slot_ui.slot_index = i
		slot_ui.slot_left_clicked.connect(_on_slot_left_clicked)
		slot_ui.slot_right_clicked.connect(_on_slot_right_clicked)
		grid_container.add_child(slot_ui)
		_slot_ui_nodes.append(slot_ui)

func refresh_ui() -> void:
	if not _inventory:
		_bind_inventory()
	if not _inventory:
		return
	
	if _slot_ui_nodes.size() != _inventory.slots.size():
		_build_grid_slots()
	
	for i in range(_inventory.slots.size()):
		var slot: InventorySlot = _inventory.slots[i]
		if i < _slot_ui_nodes.size():
			_slot_ui_nodes[i].update_slot(slot.item_id, slot.quantity, slot.durability)
			if i == _selected_slot_idx:
				_slot_ui_nodes[i].modulate = Color(1.4, 1.4, 0.7, 1.0)
			else:
				_slot_ui_nodes[i].modulate = Color.WHITE
	
	var cur_weight: float = _inventory.get_total_weight()
	var max_weight: float = _inventory.max_weight_capacity
	if weight_label:
		weight_label.text = "Weight: %.1f / %.1f kg" % [cur_weight, max_weight]
	if weight_bar:
		weight_bar.value = (cur_weight / max_weight) * 100.0 if max_weight > 0.0 else 0.0

func _on_slot_left_clicked(idx: int) -> void:
	if not _inventory:
		return
	
	if _selected_slot_idx == -1:
		# First click: select slot
		if not _inventory.slots[idx].is_empty():
			_selected_slot_idx = idx
	else:
		# Second click: swap or merge with target slot
		_inventory.swap_slots(_selected_slot_idx, idx)
		_selected_slot_idx = -1
	
	refresh_ui()

func _on_slot_right_clicked(idx: int) -> void:
	if not _inventory:
		return
	
	if _selected_slot_idx != -1 and _selected_slot_idx != idx:
		# Split half from selected into target
		var source_slot: InventorySlot = _inventory.slots[_selected_slot_idx]
		var split_amt: int = int(ceil(float(source_slot.quantity) * 0.5))
		_inventory.split_slot(_selected_slot_idx, idx, split_amt)
		_selected_slot_idx = -1
	else:
		_selected_slot_idx = idx
	
	refresh_ui()

func _sort_inventory(mode: InventoryContainer.SortMode) -> void:
	if _inventory:
		_inventory.sort_inventory(mode)
		_selected_slot_idx = -1
		refresh_ui()

func _drop_selected_item() -> void:
	if not _inventory or _selected_slot_idx == -1:
		return
	
	var slot: InventorySlot = _inventory.slots[_selected_slot_idx]
	if slot.is_empty():
		return
	
	var drop_scene: PackedScene = preload("res://scenes/items/item_drop.tscn")
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player and player.get_parent():
		var drop: ItemDrop = drop_scene.instantiate() as ItemDrop
		drop.item_id = slot.item_id
		drop.quantity = slot.quantity
		drop.durability = slot.durability
		drop.global_position = player.global_position + Vector2(randf_range(-25, 25), randf_range(20, 35))
		player.get_parent().add_child(drop)
		
		slot.clear()
		_selected_slot_idx = -1
		refresh_ui()

func _on_game_state_changed(_old_state: int, new_state: int) -> void:
	if new_state != GameStateManagerService.GameState.INVENTORY and visible:
		visible = false
		_selected_slot_idx = -1
