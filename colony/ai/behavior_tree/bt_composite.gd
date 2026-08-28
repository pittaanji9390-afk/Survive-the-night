class_name BTComposite
extends BTNode

var children: Array[BTNode] = []

func add_child(node: BTNode) -> BTComposite:
	if node:
		node.parent = self
		children.append(node)
	return self

class BTSequence extends BTComposite:
	var _current_child_idx: int = 0
	
	func tick(actor: Node2D, blackboard: Dictionary) -> NodeStatus:
		while _current_child_idx < children.size():
			var status: NodeStatus = children[_current_child_idx].tick(actor, blackboard)
			if status == NodeStatus.RUNNING:
				return NodeStatus.RUNNING
			elif status == NodeStatus.FAILURE:
				_current_child_idx = 0
				return NodeStatus.FAILURE
			_current_child_idx += 1
		
		_current_child_idx = 0
		return NodeStatus.SUCCESS

class BTSelector extends BTComposite:
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

class BTAction extends BTNode:
	var action_callable: Callable
	
	func _init(callable: Callable) -> void:
		action_callable = callable
	
	func tick(actor: Node2D, blackboard: Dictionary) -> NodeStatus:
		if action_callable.is_valid():
			return action_callable.call(actor, blackboard)
		return NodeStatus.FAILURE

class BTCondition extends BTNode:
	var predicate_callable: Callable
	
	func _init(callable: Callable) -> void:
		predicate_callable = callable
	
	func tick(actor: Node2D, blackboard: Dictionary) -> NodeStatus:
		if predicate_callable.is_valid() and predicate_callable.call(actor, blackboard):
			return NodeStatus.SUCCESS
		return NodeStatus.FAILURE
