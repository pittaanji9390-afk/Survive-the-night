class_name ChestUI
extends Control

@onready var player_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayerVBox/PlayerGrid
@onready var chest_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ChestVBox/ChestGrid
@onready var deposit_all_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/DepositAllBtn
@onready var take_all_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/TakeAllBtn
@onready var close_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseBtn

var _player_inv: InventoryContainer = null
var _chest_inv: InventoryContainer = null

var _player_slot_nodes: Array[InventorySlotUI] = []
var _chest_slot_nodes: Array[InventorySlotUI] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if deposit_all_btn:
		deposit_all_btn.pressed.connect(_deposit_all)
	if take_all_btn:
		take_all_btn.pressed.connect(_take_all)
	if close_btn:
		close_btn.pressed.connect(close_chest)

func open_chest(chest_container: InventoryContainer) -> void:
	_chest_inv = chest_container
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player:
		_player_inv = player.get_node_or_null("InventoryContainer") as InventoryContainer
	
	visible = true
	refresh_both()
	GameStateManager.change_state(GameStateManagerService.GameState.INVENTORY)

func close_chest() -> void:
	visible = false
	_chest_inv = null
	if GameStateManager.is_state(GameStateManagerService.GameState.INVENTORY):
		GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)

func refresh_both() -> void:
	_build_and_refresh_player()
	_build_and_refresh_chest()

func _build_and_refresh_player() -> void:
	if not _player_inv or not player_grid:
		return
	
	if _player_slot_nodes.size() != _player_inv.slots.size():
		for child in player_grid.get_children():
			child.queue_free()
		_player_slot_nodes.clear()
		
		var slot_scene: PackedScene = preload("res://scenes/ui/inventory_slot_ui.tscn")
		for i in range(_player_inv.slots.size()):
			var slot_ui: InventorySlotUI = slot_scene.instantiate() as InventorySlotUI
			slot_ui.slot_index = i
			var idx: int = i
			slot_ui.slot_left_clicked.connect(func(_s_idx): _transfer_player_to_chest(idx))
			player_grid.add_child(slot_ui)
			_player_slot_nodes.append(slot_ui)
	
	for i in range(_player_inv.slots.size()):
		var s: InventorySlot = _player_inv.slots[i]
		_player_slot_nodes[i].update_slot(s.item_id, s.quantity, s.durability)

func _build_and_refresh_chest() -> void:
	if not _chest_inv or not chest_grid:
		return
	
	if _chest_slot_nodes.size() != _chest_inv.slots.size():
		for child in chest_grid.get_children():
			child.queue_free()
		_chest_slot_nodes.clear()
		
		var slot_scene: PackedScene = preload("res://scenes/ui/inventory_slot_ui.tscn")
		for i in range(_chest_inv.slots.size()):
			var slot_ui: InventorySlotUI = slot_scene.instantiate() as InventorySlotUI
			slot_ui.slot_index = i
			var idx: int = i
			slot_ui.slot_left_clicked.connect(func(_s_idx): _transfer_chest_to_player(idx))
			chest_grid.add_child(slot_ui)
			_chest_slot_nodes.append(slot_ui)
	
	for i in range(_chest_inv.slots.size()):
		var s: InventorySlot = _chest_inv.slots[i]
		_chest_slot_nodes[i].update_slot(s.item_id, s.quantity, s.durability)

func _transfer_player_to_chest(slot_idx: int) -> void:
	if not _player_inv or not _chest_inv:
		return
	var s: InventorySlot = _player_inv.slots[slot_idx]
	if s.is_empty():
		return
	
	var rem: int = _chest_inv.add_item(s.item_id, s.quantity, s.durability)
	if rem == 0:
		s.clear()
	else:
		s.quantity = rem
		s.slot_changed.emit()
	
	refresh_both()

func _transfer_chest_to_player(slot_idx: int) -> void:
	if not _player_inv or not _chest_inv:
		return
	var s: InventorySlot = _chest_inv.slots[slot_idx]
	if s.is_empty():
		return
	
	var rem: int = _player_inv.add_item(s.item_id, s.quantity, s.durability)
	if rem == 0:
		s.clear()
	else:
		s.quantity = rem
		s.slot_changed.emit()
	
	refresh_both()

func _deposit_all() -> void:
	if not _player_inv or not _chest_inv:
		return
	for i in range(_player_inv.slots.size()):
		var s: InventorySlot = _player_inv.slots[i]
		if not s.is_empty():
			var rem: int = _chest_inv.add_item(s.item_id, s.quantity, s.durability)
			if rem == 0:
				s.clear()
			else:
				s.quantity = rem
	refresh_both()

func _take_all() -> void:
	if not _player_inv or not _chest_inv:
		return
	for i in range(_chest_inv.slots.size()):
		var s: InventorySlot = _chest_inv.slots[i]
		if not s.is_empty():
			var rem: int = _player_inv.add_item(s.item_id, s.quantity, s.durability)
			if rem == 0:
				s.clear()
			else:
				s.quantity = rem
	refresh_both()
