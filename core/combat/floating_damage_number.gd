class_name FloatingDamageNumber
extends Node2D

@export var damage_amount: float = 10.0
@export var is_critical: bool = false
@export var float_speed: float = 40.0
@export var lifetime_sec: float = 0.65

@onready var label: Label = $Label

var _time_alive: float = 0.0

func _ready() -> void:
	if label:
		label.text = str(int(damage_amount))
		if is_critical:
			label.text += "!"
			label.modulate = Color(1.0, 0.85, 0.2, 1.0)
			scale = Vector2(1.3, 1.3)
		else:
			label.modulate = Color(1.0, 0.35, 0.35, 1.0)

func _process(delta: float) -> void:
	_time_alive += delta
	position.y -= float_speed * delta
	
	var alpha: float = 1.0 - (_time_alive / lifetime_sec)
	modulate.a = clampf(alpha, 0.0, 1.0)
	
	if _time_alive >= lifetime_sec:
		queue_free()
