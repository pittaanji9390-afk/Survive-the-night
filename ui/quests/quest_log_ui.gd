class_name QuestLogUI
extends Control

@onready var quest_list_vbox: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/QuestListVBox
@onready var close_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/CloseBtn

var _quest_mgr: QuestManager = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if close_btn:
		close_btn.pressed.connect(toggle_visibility)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_J or event.keycode == KEY_L:
			toggle_visibility()

func toggle_visibility() -> void:
	if visible:
		visible = false
		if GameStateManager.is_state(GameStateManagerService.GameState.DIALOGUE):
			GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	else:
		_bind_manager()
		visible = true
		refresh_quests()

func _bind_manager() -> void:
	if not _quest_mgr:
		_quest_mgr = ServiceLocator.get_service(&"QuestManager") as QuestManager
		if _quest_mgr:
			_quest_mgr.quest_progress_updated.connect(func(_q): refresh_quests())
			_quest_mgr.quest_finished.connect(func(_q): refresh_quests())

func refresh_quests() -> void:
	_bind_manager()
	if not _quest_mgr or not quest_list_vbox:
		return
	
	for child in quest_list_vbox.get_children():
		child.queue_free()
	
	if _quest_mgr.active_quests.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No active quests at the moment."
		empty_lbl.modulate = Color(0.7, 0.7, 0.7, 1.0)
		quest_list_vbox.add_child(empty_lbl)
		return
	
	for q in _quest_mgr.active_quests:
		var panel: PanelContainer = PanelContainer.new()
		var vbox: VBoxContainer = VBoxContainer.new()
		
		var title_lbl: Label = Label.new()
		title_lbl.text = "%s (%d/%d)" % [q.title, q.current_count, q.target_count]
		title_lbl.theme_override_colors.font_color = Color(1.0, 0.85, 0.3, 1.0)
		vbox.add_child(title_lbl)
		
		var desc_lbl: Label = Label.new()
		desc_lbl.text = q.description
		desc_lbl.theme_override_font_sizes.font_size = 11
		desc_lbl.theme_override_colors.font_color = Color(0.8, 0.85, 0.9, 1.0)
		vbox.add_child(desc_lbl)
		
		var bar: ProgressBar = ProgressBar.new()
		bar.custom_minimum_size = Vector2(0, 10)
		bar.max_value = q.target_count
		bar.value = q.current_count
		bar.show_percentage = false
		vbox.add_child(bar)
		
		panel.add_child(vbox)
		quest_list_vbox.add_child(panel)
