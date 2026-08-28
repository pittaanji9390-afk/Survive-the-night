class_name CraftingUI
extends Control

@onready var recipe_list_vbox: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/LeftVBox/ScrollContainer/RecipeListVBox
@onready var details_name_label: Label = $PanelContainer/MarginContainer/HBoxContainer/CenterVBox/RecipeTitle
@onready var details_desc_label: Label = $PanelContainer/MarginContainer/HBoxContainer/CenterVBox/RecipeDesc
@onready var ingredients_vbox: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/CenterVBox/IngredientsVBox
@onready var station_label: Label = $PanelContainer/MarginContainer/HBoxContainer/CenterVBox/StationLabel
@onready var craft_x1_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/CenterVBox/ButtonHBox/CraftX1Btn
@onready var craft_x5_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/CenterVBox/ButtonHBox/CraftX5Btn
@onready var craft_max_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/CenterVBox/ButtonHBox/CraftMaxBtn
@onready var queue_vbox: VBoxContainer = $PanelContainer/MarginContainer/HBoxContainer/RightVBox/QueueVBox
@onready var queue_progress_bar: ProgressBar = $PanelContainer/MarginContainer/HBoxContainer/RightVBox/ActiveCraftProgressBar
@onready var close_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/RightVBox/CloseBtn

var _player: Node2D = null
var _inventory: InventoryContainer = null
var _crafting_queue: CraftingQueue = null
var _tech_tree: TechTreeManager = null

var _selected_recipe: CraftingRecipe = null
var current_station: CraftingRecipe.StationType = CraftingRecipe.StationType.HAND

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if craft_x1_btn:
		craft_x1_btn.pressed.connect(func(): _craft_selected(1))
	if craft_x5_btn:
		craft_x5_btn.pressed.connect(func(): _craft_selected(5))
	if craft_max_btn:
		craft_max_btn.pressed.connect(func(): _craft_selected(999))
	if close_btn:
		close_btn.pressed.connect(toggle_visibility)
	
	EventBus.game_state_changed.connect(_on_game_state_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_crafting"):
		toggle_visibility()

func toggle_visibility() -> void:
	if visible:
		visible = false
		if GameStateManager.is_state(GameStateManagerService.GameState.CRAFTING):
			GameStateManager.change_state(GameStateManagerService.GameState.PLAYING)
	else:
		_bind_systems()
		visible = true
		refresh_recipe_list()
		_update_selected_recipe_details()
		GameStateManager.change_state(GameStateManagerService.GameState.CRAFTING)

func _bind_systems() -> void:
	if not _player:
		_player = ServiceLocator.get_service(&"Player") as Node2D
	if _player:
		if not _inventory:
			_inventory = _player.get_node_or_null("InventoryContainer") as InventoryContainer
			if _inventory:
				_inventory.inventory_changed.connect(refresh_recipe_list)
		if not _crafting_queue:
			_crafting_queue = _player.get_node_or_null("CraftingQueue") as CraftingQueue
			if _crafting_queue:
				_crafting_queue.queue_updated.connect(_refresh_queue_ui)
				_crafting_queue.crafting_progress.connect(_on_crafting_progress)
	if not _tech_tree:
		_tech_tree = ServiceLocator.get_service(&"TechTree") as TechTreeManager

func refresh_recipe_list() -> void:
	if not recipe_list_vbox:
		return
	
	for child in recipe_list_vbox.get_children():
		child.queue_free()
	
	var all_recipes: Array[CraftingRecipe] = RecipeDatabase.get_all_recipes()
	for rec in all_recipes:
		# Check tech unlock
		if rec.tech_required != &"":
			if _tech_tree and not _tech_tree.is_tech_unlocked(rec.tech_required):
				continue
		
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(160, 32)
		btn.text = rec.display_name
		
		var can_craft: bool = rec.can_craft_with_inventory(_inventory, current_station)
		btn.modulate = Color.WHITE if can_craft else Color(0.6, 0.6, 0.6, 0.8)
		
		var recipe_ref: CraftingRecipe = rec
		btn.pressed.connect(func(): _select_recipe(recipe_ref))
		recipe_list_vbox.add_child(btn)
	
	if _selected_recipe == null and not all_recipes.is_empty():
		_selected_recipe = all_recipes[0]
	
	_update_selected_recipe_details()

func _select_recipe(rec: CraftingRecipe) -> void:
	_selected_recipe = rec
	_update_selected_recipe_details()

func _update_selected_recipe_details() -> void:
	if not _selected_recipe:
		if details_name_label:
			details_name_label.text = "Select a Recipe"
		return
	
	if details_name_label:
		details_name_label.text = _selected_recipe.display_name
	if details_desc_label:
		details_desc_label.text = _selected_recipe.description
	if station_label:
		var st_name: String = CraftingRecipe.StationType.keys()[_selected_recipe.station_required]
		station_label.text = "Station Required: %s" % st_name
	
	if ingredients_vbox:
		for child in ingredients_vbox.get_children():
			child.queue_free()
		
		for ing in _selected_recipe.ingredients:
			var item_id: StringName = ing.get("id", &"")
			var needed: int = int(ing.get("count", 1))
			var owned: int = _inventory.get_item_count(item_id) if _inventory else 0
			
			var def: ItemDefinition = ItemDatabase.get_item(item_id)
			var item_title: String = def.name if def else String(item_id)
			
			var lbl: Label = Label.new()
			lbl.text = "• %s: %d / %d" % [item_title, owned, needed]
			lbl.modulate = Color(0.3, 0.9, 0.4, 1.0) if owned >= needed else Color(0.9, 0.3, 0.3, 1.0)
			ingredients_vbox.add_child(lbl)

func _craft_selected(count: int) -> void:
	if not _selected_recipe or not _crafting_queue:
		return
	_crafting_queue.queue_recipe(_selected_recipe, count, current_station)
	refresh_recipe_list()

func _refresh_queue_ui() -> void:
	if not queue_vbox or not _crafting_queue:
		return
	
	for child in queue_vbox.get_children():
		child.queue_free()
	
	for i in range(_crafting_queue.queue.size()):
		var job = _crafting_queue.queue[i]
		var hbox: HBoxContainer = HBoxContainer.new()
		
		var lbl: Label = Label.new()
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.text = "%s (x%d)" % [job.recipe.display_name, job.batch_count]
		hbox.add_child(lbl)
		
		var cancel_btn: Button = Button.new()
		cancel_btn.text = "X"
		var job_idx: int = i
		cancel_btn.pressed.connect(func(): _crafting_queue.cancel_job(job_idx))
		hbox.add_child(cancel_btn)
		
		queue_vbox.add_child(hbox)
	
	if _crafting_queue.queue.is_empty() and queue_progress_bar:
		queue_progress_bar.value = 0.0

func _on_crafting_progress(_recipe: CraftingRecipe, ratio: float, _remaining_sec: float) -> void:
	if queue_progress_bar:
		queue_progress_bar.value = ratio * 100.0

func _on_game_state_changed(_old_state: int, new_state: int) -> void:
	if new_state != GameStateManagerService.GameState.CRAFTING and visible:
		visible = false
