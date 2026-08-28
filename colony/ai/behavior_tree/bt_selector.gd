class_name BTSelector
extends BTComposite

var _current_child_idx: int = 0

func tick(actor: Node2D, blackboard: Dictionary) -> NodeStatus:
	while _current_child_idx < children.size():
		var status: NodeStatus = children[_current_child_idx].tick(actor, blackboard)
		if status == NodeStatus.RUNNING:
			return NodeStatus.RUNNING
		elif status == NodeStatus.SUCCESS:
			_current_child_idx = 0
			return NodeStatus.SUCCESS
		_current_child_idx += 1
	
	_current_child_idx = 0
	return NodeStatus.FAILURE
