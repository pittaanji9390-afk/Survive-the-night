class_name NightSpawner
extends Node2D

@export var max_alive_enemies: int = 12
@export var spawn_interval_sec: float = 6.0
@export var spawn_distance_min: float = 340.0
@export var spawn_distance_max: float = 460.0

var _spawn_timer: float = 0.0
var _active_enemies: Array[Node2D] = []
var _player: Node2D = null

var zombie_scene: PackedScene = preload("res://scenes/enemies/zombie.tscn")
var wolf_scene: PackedScene = preload("res://scenes/enemies/wolf.tscn")
var archer_scene: PackedScene = preload("res://scenes/enemies/skeleton_archer.tscn")

func _ready() -> void:
	ServiceLocator.register_service(&"NightSpawner", self)
	EventBus.night_started.connect(_on_night_started)
	EventBus.day_started.connect(_on_day_started)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"NightSpawner")

func _process(delta: float) -> void:
	if not TimeManager.is_night():
		return
	
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval_sec
		_try_spawn_wave_enemy()

func _try_spawn_wave_enemy() -> void:
	_cleanup_dead_enemies()
	
	if _active_enemies.size() >= max_alive_enemies:
		return
	
	if not _player:
		_player = ServiceLocator.get_service(&"Player") as Node2D
	if not _player:
		return
	
	var angle: float = randf_range(0.0, TAU)
	var dist: float = randf_range(spawn_distance_min, spawn_distance_max)
	var spawn_pos: Vector2 = _player.global_position + Vector2(cos(angle), sin(angle)) * dist
	
	var chosen_scene: PackedScene = _pick_enemy_scene_for_day(TimeManager.current_day)
	var enemy: Node2D = chosen_scene.instantiate() as Node2D
	enemy.global_position = spawn_pos
	
	var parent_world: Node = get_parent()
	if parent_world:
		parent_world.add_child(enemy)
		_active_enemies.append(enemy)
		GameLogger.info("NightSpawner", "Spawned nocturnal %s at %v" % [enemy.name, spawn_pos])

func _pick_enemy_scene_for_day(day: int) -> PackedScene:
	var roll: float = randf()
	if day <= 1:
		return zombie_scene
	elif day == 2:
		return wolf_scene if roll < 0.35 else zombie_scene
	else:
		if roll < 0.25:
			return archer_scene
		elif roll < 0.55:
			return wolf_scene
		else:
			return zombie_scene

func _cleanup_dead_enemies() -> void:
	for i in range(_active_enemies.size() - 1, -1, -1):
		if not is_instance_valid(_active_enemies[i]):
			_active_enemies.remove_at(i)

func _on_night_started(night_num: int) -> void:
	EventBus.notification_posted.emit("Nightfall", "Night %d has begun! Nocturnal beasts emerge." % night_num, "warning")
	EventBus.wave_started.emit(night_num, max_alive_enemies)
	_spawn_timer = 2.0 # Fast initial spawn

func _on_day_started(day_num: int) -> void:
	EventBus.notification_posted.emit("Dawn", "The sun rises on Day %d. You survived the night!" % day_num, "dawn")
	EventBus.wave_completed.emit(day_num - 1)
	
	# Burn / banish surviving nocturnal enemies
	for enemy in _active_enemies:
		if is_instance_valid(enemy) and enemy.has_method("die"):
			enemy.die(null)
	_active_enemies.clear()
