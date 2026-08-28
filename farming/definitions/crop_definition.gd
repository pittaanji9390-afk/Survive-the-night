class_name CropDefinition
extends Resource

@export var crop_id: StringName = &"crop_wheat"
@export var crop_name: String = "Wheat"
@export var seed_item_id: StringName = &"seed_wheat"
@export var harvest_item_id: StringName = &"wheat"
@export var harvest_yield_min: int = 2
@export var harvest_yield_max: int = 4
@export var growth_stages: int = 3
@export var growth_time_per_stage_sec: float = 8.0
@export var water_required: bool = true
@export var experience_reward: int = 10
