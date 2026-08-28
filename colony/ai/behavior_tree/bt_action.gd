class_name BTAction
extends BTNode

var action_callable: Callable

func _init(callable: Callable = Callable()) -> void:
	action_callable = callable

func tick(actor: Node2D, blackboard: Dictionary) -> NodeStatus:
	if not action_callable.is_null():
		return action_callable.call(actor, blackboard)
	return BTNode.NodeStatus.FAILURE
