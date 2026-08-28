class_name TestColonySimulation
extends RefCounted

const BTSequenceClass = preload("res://colony/ai/behavior_tree/bt_sequence.gd")
const BTConditionClass = preload("res://colony/ai/behavior_tree/bt_condition.gd")
const BTActionClass = preload("res://colony/ai/behavior_tree/bt_action.gd")

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_colonist_needs_decay())
	results.append(_test_behavior_tree_evaluation())
	results.append(_test_job_assignment_and_work())
	return results

func _test_colonist_needs_decay() -> Dictionary:
	var needs: ColonistNeeds = ColonistNeeds.new()
	needs.hunger = 100.0
	needs.rest = 100.0
	
	needs.update_needs(10.0) # 10s decay
	
	var passed: bool = (needs.hunger < 100.0) and (needs.rest < 100.0) and (needs.get_overall_morale() > 0.0)
	return {"name": "Colony: Needs Decay & Morale Score", "passed": passed, "message": "Hunger and Rest decayed normally"}

func _test_behavior_tree_evaluation() -> Dictionary:
	var root = BTSequenceClass.new()
	var executed: bool = false
	
	var cond = BTConditionClass.new(func(_a, _bb): return true)
	var act = BTActionClass.new(func(_a, _bb):
		return BTNode.NodeStatus.SUCCESS
	)
	
	root.add_child(cond)
	root.add_child(act)
	
	var status = root.tick(null, {})
	var passed: bool = (status == BTNode.NodeStatus.SUCCESS) and (root.children.size() == 2)
	return {"name": "Colony: Behavior Tree Execution Flow", "passed": passed, "message": "Status: %d, Children: %d" % [status, root.children.size()]}

func _test_job_assignment_and_work() -> Dictionary:
	var j_mgr: JobManager = JobManager.new()
	j_mgr._ready()
	
	var job: JobDefinition = j_mgr.create_job(JobDefinition.JobType.CHOP_TREE, Vector2(100, 100), null, 2.0)
	var assigned: JobDefinition = j_mgr.request_job(&"Marcus", Vector2(0, 0))
	
	var same_job: bool = (job == assigned) and (job.assigned_colonist_id == &"Marcus")
	
	var finished: bool = job.add_work(2.0)
	j_mgr.finish_job(job)
	
	var passed: bool = same_job and finished and j_mgr.active_jobs.is_empty()
	j_mgr.free()
	return {"name": "Colony: Job Queue & Assignment Dispatch", "passed": passed, "message": "Job created, worked, and finished"}
