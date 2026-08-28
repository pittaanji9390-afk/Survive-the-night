class_name DialogueUI
extends Control

@onready var name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/NameLabel
@onready var role_label: Label = $PanelContainer/MarginContainer/VBoxContainer/RoleLabel
@onready var text_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TextLabel
@onready var next_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/NextBtn
@onready var trade_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonHBox/TradeBtn
@onready var close_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseBtn

var _current_npc: NPCDefinition = null
var _line_index: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if next_btn:
		next_btn.pressed.connect(_on_next_pressed)
	if trade_btn:
		trade_btn.pressed.connect(_on_trade_pressed)
	if close_btn:
		close_btn.pressed.connect(close_dialogue)

func open_dialogue(npc: NPCDefinition) -> void:
	_current_npc = npc
	_line_index = 0
	visible = true
	
	if name_label:
		name_label.text = npc.npc_name
	if role_label:
		role_label.text = npc.role_title
	
	if trade_btn:
		trade_btn.visible = not npc.trade_offers.is_empty()
	
	_show_current_line()
	GameStateManager.change_state(GameStateManagerService.GameState.DIALOGUE)

func close_dialogue() -> void:
	visible = false
	if _current_npc:
		EventBus.dialogue_ended.emit(_current_npc.npc_id)
	_current_npc = null
	if GameStateManager.is_state(GameStateManagerService.GameState.DIALOGUE):
		GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)

func _show_current_line() -> void:
	if not _current_npc or not text_label:
		return
	
	if _line_index < _current_npc.dialogue_lines.size():
		text_label.text = _current_npc.dialogue_lines[_line_index]
	else:
		close_dialogue()

func _on_next_pressed() -> void:
	if not _current_npc:
		return
	_line_index += 1
	if _line_index >= _current_npc.dialogue_lines.size():
		close_dialogue()
	else:
		_show_current_line()

func _on_trade_pressed() -> void:
	if not _current_npc:
		return
	var canvas: CanvasLayer = get_parent() as CanvasLayer
	if canvas:
		var trade_ui: TradingUI = canvas.get_node_or_null("TradingUI") as TradingUI
		if trade_ui:
			visible = false
			trade_ui.open_trading(_current_npc)
