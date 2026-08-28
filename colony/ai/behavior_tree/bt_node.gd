class_name BTNode
extends RefCounted

enum NodeStatus {
	SUCCESS,
	FAILURE,
	RUNNING
}

var parent: BTNode = null

func tick(_actor: Node2D, _blackboard: Dictionary) -> NodeStatus:
	return NodeStatus.SUCCESS
