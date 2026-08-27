class_name CameraController
extends Camera2D

@export var target_node: Node2D
@export var follow_speed: float = 8.0
@export var max_shake_offset: Vector2 = Vector2(16.0, 12.0)
@export var max_shake_rotation: float = 0.05 # Radians
@export var trauma_decay: float = 1.5

var trauma: float = 0.0
var _noise: FastNoiseLite
var _noise_y: float = 0.0

func _ready() -> void:
	_noise = FastNoiseLite.new()
	_noise.seed = randi()
	_noise.frequency = 4.0
	
	EventBus.screen_shake_requested.connect(add_trauma)

func _process(delta: float) -> void:
	_follow_target(delta)
	_process_shake(delta)

func _follow_target(delta: float) -> void:
	if is_instance_valid(target_node):
		global_position = global_position.lerp(target_node.global_position, follow_speed * delta)

func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)

func _process_shake(delta: float) -> void:
	if trauma <= 0.0:
		offset = Vector2.ZERO
		rotation = 0.0
		return
	
	trauma = maxf(0.0, trauma - trauma_decay * delta)
	var shake_power: float = trauma * trauma # Quadratic curve for natural feel
	_noise_y += delta * 60.0
	
	var shake_x: float = _noise.get_noise_2d(0.0, _noise_y) * max_shake_offset.x * shake_power
	var shake_y: float = _noise.get_noise_2d(100.0, _noise_y) * max_shake_offset.y * shake_power
	var shake_rot: float = _noise.get_noise_2d(200.0, _noise_y) * max_shake_rotation * shake_power
	
	offset = Vector2(shake_x, shake_y)
	rotation = shake_rot
