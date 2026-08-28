class_name FarmPlot
extends StructureInstance

signal crop_planted(crop_id: StringName)
signal crop_harvested(crop_id: StringName, count: int)

enum PlotState {
	EMPTY,
	GROWING,
	MATURE
}

@export var current_state: PlotState = PlotState.EMPTY
@export var current_crop_id: StringName = &""
@export var current_stage: int = 0
@export var is_watered: bool = false

var _growth_timer: float = 0.0

func _ready() -> void:
	structure_id = &"farm_plot"
	super._ready()

func _process(delta: float) -> void:
	if current_state != PlotState.GROWING:
		return
	
	var def: CropDefinition = CropDatabase.get_crop(current_crop_id)
	if not def or def.growth_time_per_stage_sec <= 0.0:
		return
	
	var growth_speed: float = 2.0 if is_watered else 1.0
	_growth_timer += delta * growth_speed
	
	while _growth_timer >= def.growth_time_per_stage_sec:
		_growth_timer -= def.growth_time_per_stage_sec
		current_stage += 1
		
		if current_stage >= def.growth_stages:
			current_state = PlotState.MATURE
			is_watered = false
			break
	
	_update_crop_visuals()

func get_interaction_prompt() -> String:
	match current_state:
		PlotState.EMPTY:
			return "[E] Sow Seed"
		PlotState.GROWING:
			return "[E] Water Crop" if not is_watered else "Growing (Watered)"
		PlotState.MATURE:
			return "[E] Harvest Crop"
	return "Farm Plot"

func interact(player: Node2D) -> void:
	var p_ctrl: PlayerController = player as PlayerController
	if not p_ctrl or not p_ctrl.inventory:
		return
	
	match current_state:
		PlotState.EMPTY:
			_try_plant_seed(p_ctrl)
		PlotState.GROWING:
			water_plot()
		PlotState.MATURE:
			_harvest(p_ctrl)

func _try_plant_seed(player: PlayerController) -> void:
	var crop_def: CropDefinition = CropDatabase.get_crop(&"crop_wheat")
	if crop_def:
		plant_crop(crop_def.crop_id)
		EventBus.notification_posted.emit("Farming", "Planted Wheat Seed", "farm")

func plant_crop(crop_id: StringName) -> void:
	current_crop_id = crop_id
	current_stage = 0
	_growth_timer = 0.0
	current_state = PlotState.GROWING
	is_watered = true
	_update_crop_visuals()
	crop_planted.emit(crop_id)

func water_plot() -> void:
	is_watered = true
	_update_crop_visuals()
	EventBus.notification_posted.emit("Farming", "Watered soil (Growth 2x)", "water")

func _harvest(player: PlayerController) -> void:
	var def: CropDefinition = CropDatabase.get_crop(current_crop_id)
	if not def:
		return
	
	var yield_count: int = randi_range(def.harvest_yield_min, def.harvest_yield_max)
	if player and player.inventory:
		player.inventory.add_item(def.harvest_item_id, yield_count)
	
	var msg: String = "Harvested %d x %s!" % [yield_count, def.crop_name]
	EventBus.notification_posted.emit("Harvest", msg, "farm")
	GameLogger.info("Farming", msg)
	
	crop_harvested.emit(current_crop_id, yield_count)
	
	current_state = PlotState.EMPTY
	current_crop_id = &""
	current_stage = 0
	is_watered = false
	_update_crop_visuals()

func _update_crop_visuals() -> void:
	if not sprite:
		return
	var t: Tween = create_tween()
	if current_state == PlotState.MATURE:
		sprite.modulate = Color(1.2, 1.1, 0.4, 1.0)
		t.tween_property(sprite, "scale", _base_scale * Vector2(1.2, 1.2), 0.15)
	elif current_state == PlotState.GROWING:
		sprite.modulate = Color(0.5, 0.9, 0.4, 1.0) if is_watered else Color(0.7, 0.8, 0.6, 1.0)
	else:
		sprite.modulate = Color.WHITE
		t.tween_property(sprite, "scale", _base_scale, 0.1)
