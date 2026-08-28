class_name StructureDefinition
extends Resource

enum StructureType {
	FLOOR,
	WALL,
	DOOR,
	WINDOW,
	STORAGE,
	DEFENSE_TRAP,
	LIGHT,
	FARM_PLOT,
	UTILITY,
	BED
}

enum MaterialType {
	WOOD,
	STONE,
	IRON,
	HAY
}

@export var structure_id: StringName = &"struct_default"
@export var display_name: String = "Structure"
@export_multiline var description: String = "Building structure."
@export var structure_type: StructureType = StructureType.WALL
@export var material_type: MaterialType = MaterialType.WOOD
@export var size_in_tiles: Vector2i = Vector2i(1, 1)

@export var max_health: float = 100.0
@export var armor: float = 0.0
@export var is_passable: bool = false
@export var can_rotate: bool = false

# Array of Dictionaries: [{ "id": StringName, "count": int }]
@export var construction_costs: Array[Dictionary] = []

@export var upgrade_structure_id: StringName = &""
@export var refund_ratio_on_destroy: float = 0.5

func can_build(inventory: InventoryContainer) -> bool:
	if not inventory:
		return false
	for cost in construction_costs:
		var item_id: StringName = cost.get("id", &"")
		var count: int = int(cost.get("count", 1))
		if inventory.get_item_count(item_id) < count:
			return false
	return true

func consume_costs(inventory: InventoryContainer) -> bool:
	if not can_build(inventory):
		return false
	for cost in construction_costs:
		var item_id: StringName = cost.get("id", &"")
		var count: int = int(cost.get("count", 1))
		inventory.remove_item(item_id, count)
	return true

func refund_costs(inventory: InventoryContainer) -> void:
	if not inventory:
		return
	for cost in construction_costs:
		var item_id: StringName = cost.get("id", &"")
		var count: int = int(cost.get("count", 1))
		var refund_count: int = int(floor(float(count) * refund_ratio_on_destroy))
		if refund_count > 0:
			inventory.add_item(item_id, refund_count)
