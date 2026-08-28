class_name SpellDefinition
extends Resource

enum ElementType {
	FIRE,
	FROST,
	LIGHTNING,
	NATURE,
	ARCANE
}

@export var spell_id: StringName = &"spell_fireball"
@export var spell_name: String = "Fireball"
@export var element: ElementType = ElementType.FIRE
@export var mana_cost: float = 25.0
@export var damage: float = 40.0
@export var cooldown_sec: float = 1.2
@export var aoe_radius: float = 32.0
