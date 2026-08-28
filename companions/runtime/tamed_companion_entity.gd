class_name TamedCompanionEntity
extends CharacterBody2D

signal companion_leveled_up(level: int)

@export var companion_name: String = "Shadow"
@export var current_stance: CompanionDefinition.CompanionStance = CompanionDefinition.CompanionStance.FOLLOW
@export var max_health: float = 120.0
@export var current_health: float = 120.0
@export var attack_damage: float = 18.0
@export var companion_level: int = 1
@export var is_mounted: bool = false

var _target_player: Node2D = null

func _ready() -> void:
	add_to_group("companion")
	add_to_group("friendly")

func set_stance(stance: CompanionDefinition.CompanionStance) -> void:
	current_stance = stance
	var stance_name: String = "Follow" if stance == CompanionDefinition.CompanionStance.FOLLOW else "Guard"
	EventBus.notification_posted.emit("Companion", "%s stance: %s" % [companion_name, stance_name], "pet")

func mount_player(player: PlayerController) -> void:
	is_mounted = true
	if player and player.stats:
		player.stats.speed.add_modifier("mount_bonus", 50.0, StatAttribute.ModifierType.FLAT)
	EventBus.notification_posted.emit("Mounted", "Riding %s (+50 Speed)" % companion_name, "mount")

func dismount_player(player: PlayerController) -> void:
	is_mounted = false
	if player and player.stats:
		player.stats.speed.remove_modifier("mount_bonus")
	EventBus.notification_posted.emit("Dismounted", "Dismounted %s" % companion_name, "mount")

func level_up() -> void:
	companion_level += 1
	max_health += 15.0
	current_health = max_health
	attack_damage += 3.0
	companion_leveled_up.emit(companion_level)
	EventBus.notification_posted.emit("Pet Level Up", "%s reached Level %d!" % [companion_name, companion_level], "level")
