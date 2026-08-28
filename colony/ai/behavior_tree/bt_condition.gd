class_name BTCondition
extends BTNode

var predicate_callable: Callable

func _init(callable: Callable = Callable()) -> void:
	predicate_callable = callable

func tick(actor: Node2D, blackboard: Dictionary) -> NodeStatus:
	if not predicate_callable.is_null():
		var result = predicate_callable.call(actor, blackboard)
		if result:
			return BTNode.NodeStatus.SUCCESS
	return BTNode.NodeStatus.FAILURE
