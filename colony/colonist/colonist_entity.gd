class_name ColonistEntity
extends CharacterBody2D

const BTSelectorClass = preload("res://colony/ai/behavior_tree/bt_selector.gd")
const BTSequenceClass = preload("res://colony/ai/behavior_tree/bt_sequence.gd")
const BTActionClass = preload("res://colony/ai/behavior_tree/bt_action.gd")
const BTConditionClass = preload("res://colony/ai/behavior_tree/bt_condition.gd")

@export var colonist_name: String = "Marcus"
@export var move_speed: float = 100.0

var needs: ColonistNeeds = ColonistNeeds.new()
var current_job: JobDefinition = null
var behavior_tree: BTNode = null

func _ready() -> void:
	add_to_group("colonist")
	add_to_group("friendly")
	_build_behavior_tree()

func _physics_process(delta: float) -> void:
	needs.update_needs(delta)
	
	if behavior_tree:
		var bb: Dictionary = {}
		behavior_tree.tick(self, bb)

func _build_behavior_tree() -> void:
	var root = BTSelectorClass.new()
	
	# 1. Eat if starving
	var eat_seq = BTSequenceClass.new()
	eat_seq.add_child(BTConditionClass.new(func(_a, _bb): return needs.hunger < 25.0))
	eat_seq.add_child(BTActionClass.new(func(_a, _bb):
		needs.feed(50.0)
		return BTNode.NodeStatus.SUCCESS
	))
	root.add_child(eat_seq)
	
	# 2. Sleep if exhausted
	var sleep_seq = BTSequenceClass.new()
	sleep_seq.add_child(BTConditionClass.new(func(_a, _bb): return needs.rest < 20.0))
	sleep_seq.add_child(BTActionClass.new(func(_a, _bb):
		needs.sleep(60.0)
		return BTNode.NodeStatus.SUCCESS
	))
	root.add_child(sleep_seq)
	
	# 3. Work on assigned job
	var work_seq = BTSequenceClass.new()
	work_seq.add_child(BTActionClass.new(func(actor: Node2D, _bb):
		var col: ColonistEntity = actor as ColonistEntity
		if not col.current_job:
			var j_mgr: JobManager = ServiceLocator.get_service(&"JobManager") as JobManager
			if j_mgr:
				col.current_job = j_mgr.request_job(StringName(col.colonist_name), col.global_position)
		
		if not col.current_job:
			return BTNode.NodeStatus.FAILURE
		
		var dist: float = col.global_position.distance_to(col.current_job.target_position)
		if dist > 24.0:
			var dir: Vector2 = (col.current_job.target_position - col.global_position).normalized()
			col.velocity = dir * col.move_speed
			col.move_and_slide()
			return BTNode.NodeStatus.RUNNING
		else:
			var finished: bool = col.current_job.add_work(0.1)
			if finished:
				var j_mgr: JobManager = ServiceLocator.get_service(&"JobManager") as JobManager
				if j_mgr:
					j_mgr.finish_job(col.current_job)
				col.current_job = null
				return BTNode.NodeStatus.SUCCESS
			return BTNode.NodeStatus.RUNNING
	))
	root.add_child(work_seq)
	
	behavior_tree = root
