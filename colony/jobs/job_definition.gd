class_name JobDefinition
extends RefCounted

enum JobType {
	HAUL_ITEM,
	CHOP_TREE,
	MINE_ROCK,
	FARM_HARVEST,
	BUILD_STRUCTURE,
	GUARD_BASE
}

var job_id: StringName = &"job_default"
var job_type: JobType = JobType.HAUL_ITEM
var target_position: Vector2 = Vector2.ZERO
var target_node: Node2D = null
var work_required_sec: float = 2.0
var work_progress_sec: float = 0.0
var is_completed: bool = false
var assigned_colonist_id: StringName = &""

func add_work(amount_sec: float) -> bool:
	if is_completed:
		return true
	work_progress_sec += amount_sec
	if work_progress_sec >= work_required_sec:
		is_completed = true
		return true
	return false
