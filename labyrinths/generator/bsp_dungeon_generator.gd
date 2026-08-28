class_name BSPDungeonGenerator
extends RefCounted

class BSPRoom:
	var rect: Rect2i
	var left_child: BSPRoom = null
	var right_child: BSPRoom = null
	var room_rect: Rect2i
	
	func _init(r: Rect2i) -> void:
		rect = r
		room_rect = r

var width: int = 50
var height: int = 50
var min_leaf_size: int = 10
var rooms: Array[Rect2i] = []

func _init(w: int = 50, h: int = 50, leaf_min: int = 10) -> void:
	width = w
	height = h
	min_leaf_size = leaf_min

func generate_bsp() -> Array[Rect2i]:
	rooms.clear()
	var root: BSPRoom = BSPRoom.new(Rect2i(0, 0, width, height))
	_split_leaf(root, 3) # 3 levels of recursive splitting
	_create_rooms(root)
	return rooms

func _split_leaf(leaf: BSPRoom, depth: int) -> void:
	if depth <= 0:
		return
	
	var split_horizontally: bool = randf() > 0.5
	if leaf.rect.size.x > leaf.rect.size.y and leaf.rect.size.x / float(leaf.rect.size.y) >= 1.25:
		split_horizontally = false
	elif leaf.rect.size.y > leaf.rect.size.x and leaf.rect.size.y / float(leaf.rect.size.x) >= 1.25:
		split_horizontally = true
	
	var max_split: int = (leaf.rect.size.y if split_horizontally else leaf.rect.size.x) - min_leaf_size
	if max_split <= min_leaf_size:
		return
	
	var split: int = randi_range(min_leaf_size, max_split)
	if split_horizontally:
		leaf.left_child = BSPRoom.new(Rect2i(leaf.rect.position.x, leaf.rect.position.y, leaf.rect.size.x, split))
		leaf.right_child = BSPRoom.new(Rect2i(leaf.rect.position.x, leaf.rect.position.y + split, leaf.rect.size.x, leaf.rect.size.y - split))
	else:
		leaf.left_child = BSPRoom.new(Rect2i(leaf.rect.position.x, leaf.rect.position.y, split, leaf.rect.size.y))
		leaf.right_child = BSPRoom.new(Rect2i(leaf.rect.position.x + split, leaf.rect.position.y, leaf.rect.size.x - split, leaf.rect.size.y))
	
	_split_leaf(leaf.left_child, depth - 1)
	_split_leaf(leaf.right_child, depth - 1)

func _create_rooms(leaf: BSPRoom) -> void:
	if leaf.left_child != null or leaf.right_child != null:
		if leaf.left_child != null: _create_rooms(leaf.left_child)
		if leaf.right_child != null: _create_rooms(leaf.right_child)
	else:
		var room_w: int = leaf.rect.size.x - 2
		var room_h: int = leaf.rect.size.y - 2
		if room_w >= 4 and room_h >= 4:
			var r: Rect2i = Rect2i(leaf.rect.position.x + 1, leaf.rect.position.y + 1, room_w, room_h)
			leaf.room_rect = r
			rooms.append(r)
