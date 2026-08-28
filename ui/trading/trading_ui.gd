class_name TradingUI
extends Control

@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/TitleLabel
@onready var trades_vbox: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/TradesVBox
@onready var close_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseBtn

var _current_npc: NPCDefinition = null
var _inventory: InventoryContainer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_trading)

func open_trading(npc: NPCDefinition) -> void:
	_current_npc = npc
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player:
		_inventory = player.get_node_or_null("InventoryContainer") as InventoryContainer
	
	visible = true
	if title_label:
		title_label.text = "MERCHANT SHOP - %s" % npc.npc_name.to_upper()
	
	refresh_trades()
	GameStateManager.change_state(GameStateManagerService.GameState.DIALOGUE)

func close_trading() -> void:
	visible = false
	_current_npc = null
	if GameStateManager.is_state(GameStateManagerService.GameState.DIALOGUE):
		GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)

func refresh_trades() -> void:
	if not _current_npc or not trades_vbox:
		return
	
	for child in trades_vbox.get_children():
		child.queue_free()
	
	for trade in _current_npc.trade_offers:
		var cost_id: StringName = trade.get("cost_id", &"")
		var cost_count: int = int(trade.get("cost_count", 1))
		var reward_id: StringName = trade.get("reward_id", &"")
		var reward_count: int = int(trade.get("reward_count", 1))
		
		var owned: int = _inventory.get_item_count(cost_id) if _inventory else 0
		var can_trade: bool = owned >= cost_count
		
		var hbox: HBoxContainer = HBoxContainer.new()
		var lbl: Label = Label.new()
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.text = "Pay: %d x %s (%d owned) -> Get: %d x %s" % [cost_count, cost_id, owned, reward_count, reward_id]
		lbl.modulate = Color.WHITE if can_trade else Color(0.65, 0.65, 0.65, 0.75)
		hbox.add_child(lbl)
		
		var buy_btn: Button = Button.new()
		buy_btn.text = "Exchange"
		buy_btn.disabled = not can_trade
		
		var tr_copy: Dictionary = trade
		buy_btn.pressed.connect(func(): _execute_trade(tr_copy))
		hbox.add_child(buy_btn)
		
		trades_vbox.add_child(hbox)

func _execute_trade(trade: Dictionary) -> void:
	if not _inventory:
		return
	
	var cost_id: StringName = trade.get("cost_id", &"")
	var cost_count: int = int(trade.get("cost_count", 1))
	var reward_id: StringName = trade.get("reward_id", &"")
	var reward_count: int = int(trade.get("reward_count", 1))
	
	if _inventory.get_item_count(cost_id) >= cost_count:
		_inventory.remove_item(cost_id, cost_count)
		_inventory.add_item(reward_id, reward_count)
		EventBus.notification_posted.emit("Trade Completed", "Received %d x %s" % [reward_count, reward_id], "trade")
		refresh_trades()
