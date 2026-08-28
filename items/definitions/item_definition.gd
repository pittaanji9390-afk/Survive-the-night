class_name ItemDefinition
extends Resource

enum Category {
	RESOURCE,
	FOOD,
	TOOL,
	WEAPON,
	ARMOR,
	MATERIAL,
	BUILDING,
	QUEST,
	CONSUMABLE,
	SEED,
	MISCELLANEOUS
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

enum ToolType {
	NONE,
	AXE,
	PICKAXE,
	SWORD,
	BOW,
	SCYTHE,
	SHOVEL
}

enum EquipmentSlotType {
	NONE,
	MAIN_HAND,
	OFF_HAND,
	HEAD,
	CHEST,
	LEGS,
	FEET,
	ACCESSORY
}

@export var id: StringName = &"item_default"
@export var name: String = "Default Item"
@export_multiline var description: String = "A standard item."
@export var icon: Texture2D
@export var category: Category = Category.RESOURCE
@export var rarity: Rarity = Rarity.COMMON
@export var max_stack: int = 99
@export var weight: float = 0.5
@export var value: int = 1
@export var max_durability: int = 0 # 0 means indestructible / no durability
@export var tags: Array[StringName] = []

# Tool & Combat Properties
@export var tool_type: ToolType = ToolType.NONE
@export var tool_tier: int = 0 # 0=Hand, 1=Wood, 2=Stone, 3=Iron, 4=Steel
@export var base_damage: float = 0.0
@export var attack_speed: float = 1.0
@export var attack_range: float = 40.0
@export var stamina_cost_per_use: float = 5.0

# Equipment & Armor Properties
@export var equip_slot: EquipmentSlotType = EquipmentSlotType.NONE
@export var defense_bonus: float = 0.0
@export var speed_modifier: float = 0.0
@export var max_health_bonus: float = 0.0
@export var max_stamina_bonus: float = 0.0

# Consumable / Food Properties
@export var health_restore: float = 0.0
@export var stamina_restore: float = 0.0
@export var hunger_restore: float = 0.0
@export var use_duration_sec: float = 0.0

func is_stackable() -> bool:
	return max_stack > 1 and max_durability == 0

func is_equipment() -> bool:
	return equip_slot != EquipmentSlotType.NONE

func is_tool() -> bool:
	return tool_type != ToolType.NONE

func is_consumable() -> bool:
	return category == Category.FOOD or category == Category.CONSUMABLE

func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color(0.85, 0.85, 0.85, 1.0)
		Rarity.UNCOMMON: return Color(0.3, 0.9, 0.4, 1.0)
		Rarity.RARE: return Color(0.25, 0.65, 1.0, 1.0)
		Rarity.EPIC: return Color(0.75, 0.35, 0.95, 1.0)
		Rarity.LEGENDARY: return Color(1.0, 0.75, 0.15, 1.0)
	return Color.WHITE
