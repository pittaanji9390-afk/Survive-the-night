class_name BoatEntity
extends CharacterBody2D

signal boat_damaged(cur_hp: float, max_hp: float)
signal boat_sunk()

@export var max_hull_hp: float = 300.0
@export var current_hull_hp: float = 300.0
@export var cruising_speed: float = 160.0
@export var is_piloted: bool = false

func _ready() -> void:
	add_to_group("boat")
	add_to_group("vehicle")

func board_boat(player: PlayerController) -> void:
	is_piloted = true
	if player and player.stats:
		player.stats.speed.add_modifier("boat_speed", 80.0, StatAttribute.ModifierType.FLAT)
	EventBus.notification_posted.emit("Embarked", "Now sailing on the open seas.", "anchor")

func disembark_boat(player: PlayerController) -> void:
	is_piloted = false
	if player and player.stats:
		player.stats.speed.remove_modifier("boat_speed")
	EventBus.notification_posted.emit("Disembarked", "Returned to dry land.", "anchor")

func take_hull_damage(amount: float) -> void:
	current_hull_hp = maxf(0.0, current_hull_hp - amount)
	boat_damaged.emit(current_hull_hp, max_hull_hp)
	if current_hull_hp <= 0.0:
		boat_sunk.emit()
		EventBus.notification_posted.emit("SHIPWRECK!", "Your vessel has succumbed to the deep!", "danger")
