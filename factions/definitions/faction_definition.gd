class_name FactionDefinition
extends Resource

enum FactionStance {
	HOSTILE,
	NEUTRAL,
	ALLIED
}

@export var faction_id: StringName = &"faction_iron_vanguard"
@export var faction_name: String = "Iron Vanguard"
@export var reputation: int = 0 # -100 to +100

func get_stance() -> FactionStance:
	if reputation <= -30:
		return FactionStance.HOSTILE
	elif reputation >= 50:
		return FactionStance.ALLIED
	return FactionStance.NEUTRAL

func modify_reputation(delta: int) -> void:
	reputation = clampi(reputation + delta, -100, 100)
