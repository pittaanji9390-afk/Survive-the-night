class_name DungeonManager
extends Node2D

signal dungeon_entered(level: int)
signal dungeon_exited()

var is_in_dungeon: bool = false
var current_level: int = 1
var surface_return_pos: Vector2 = Vector2.ZERO

var _generator: DungeonGenerator = null
var _dungeon_container: Node2D = null

func _ready() -> void:
	ServiceLocator.register_service(&"DungeonManager", self)
	_dungeon_container = Node2D.new()
	_dungeon_container.name = "DungeonCaverns"
	add_child(_dungeon_container)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"DungeonManager")

func enter_dungeon(level: int = 1) -> void:
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player:
		surface_return_pos = player.global_position
	
	is_in_dungeon = true
	current_level = level
	
	_generate_and_populate_dungeon()
	
	# Set underground darkness
	var time_mgr: TimeManager = ServiceLocator.get_service(&"TimeManager") as TimeManager
	
	EventBus.notification_posted.emit("SUBTERRANEAN DEPTHS", "Entered Dungeon Level %d" % level, "dungeon")
	dungeon_entered.emit(level)
	GameLogger.info("DungeonManager", "Entered dungeon level %d" % level)

func exit_dungeon() -> void:
	is_in_dungeon = false
	_clear_dungeon()
	
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	if player:
		player.global_position = surface_return_pos
	
	EventBus.notification_posted.emit("SURFACE SANCTUARY", "Returned to surface world.", "sun")
	dungeon_exited.emit()
	GameLogger.info("DungeonManager", "Returned to surface world.")

func _generate_and_populate_dungeon() -> void:
	_clear_dungeon()
	_generator = DungeonGenerator.new(35, 35, 1000 + current_level * 333)
	var grid: Array = _generator.generate_dungeon()
	
	var player_placed: bool = false
	var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var tile: int = grid[y][x]
			var world_pos: Vector2 = Vector2(x * 32.0, y * 32.0)
			
			if tile == DungeonGenerator.TileType.ENTRANCE_LADDER:
				if player and not player_placed:
					player.global_position = world_pos
					player_placed = true
			elif tile == DungeonGenerator.TileType.EXIT_LADDER:
				_spawn_boss_arena(world_pos)
			elif tile == DungeonGenerator.TileType.WALL:
				_spawn_wall(world_pos)

func _spawn_wall(pos: Vector2) -> void:
	var wall: StaticBody2D = StaticBody2D.new()
	wall.position = pos
	wall.collision_layer = 6
	wall.collision_mask = 0
	
	var col: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(32, 32)
	col.shape = rect
	wall.add_child(col)
	_dungeon_container.add_child(wall)

func _spawn_boss_arena(pos: Vector2) -> void:
	var boss_scene: PackedScene = load("res://scenes/enemies/boss_broodmother.tscn")
	if boss_scene:
		var boss: Node2D = boss_scene.instantiate() as Node2D
		boss.position = pos
		_dungeon_container.add_child(boss)

func _clear_dungeon() -> void:
	if _dungeon_container:
		for child in _dungeon_container.get_children():
			child.queue_free()
