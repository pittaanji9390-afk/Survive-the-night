class_name JobManager
extends Node

signal job_created(job: JobDefinition)
signal job_completed(job: JobDefinition)

var available_jobs: Array[JobDefinition] = []
var active_jobs: Array[JobDefinition] = []

func _ready() -> void:
	ServiceLocator.register_service(&"JobManager", self)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"JobManager")

func create_job(j_type: JobDefinition.JobType, target_pos: Vector2, target: Node2D = null, work_time: float = 2.0) -> JobDefinition:
	var job: JobDefinition = JobDefinition.new()
	job.job_id = StringName("job_%d" % (available_jobs.size() + active_jobs.size() + 1))
	job.job_type = j_type
	job.target_position = target_pos
	job.target_node = target
	job.work_required_sec = work_time
	available_jobs.append(job)
	job_created.emit(job)
	return job

func request_job(colonist_id: StringName, colonist_pos: Vector2) -> JobDefinition:
	if available_jobs.is_empty():
		return null
	
	# Find nearest available job
	var best_idx: int = 0
	var best_dist: float = colonist_pos.distance_to(available_jobs[0].target_position)
	
	for i in range(1, available_jobs.size()):
		var dist: float = colonist_pos.distance_to(available_jobs[i].target_position)
		if dist < best_dist:
			best_dist = dist
			best_idx = i
	
	var job: JobDefinition = available_jobs[best_idx]
	available_jobs.remove_at(best_idx)
	job.assigned_colonist_id = colonist_id
	active_jobs.append(job)
	return job

func finish_job(job: JobDefinition) -> void:
	active_jobs.erase(job)
	job_completed.emit(job)
