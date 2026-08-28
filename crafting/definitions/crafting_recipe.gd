class_name CraftingRecipe
extends Resource

enum StationType {
	HAND,
	CAMPFIRE,
	WORKBENCH,
	FURNACE,
	ANVIL,
	ALCHEMY
}

@export var recipe_id: StringName = &"recipe_default"
@export var display_name: String = "Crafting Recipe"
@export_multiline var description: String = "Recipe description."
@export var category: ItemDefinition.Category = ItemDefinition.Category.MATERIAL
@export var station_required: StationType = StationType.HAND
@export var craft_time_sec: float = 1.5
@export var tech_required: StringName = &""
@export var unlocked_by_default: bool = true
@export var experience_reward: int = 5

# Array of Dictionaries: [{ "id": StringName, "count": int }]
@export var ingredients: Array[Dictionary] = []

# Array of Dictionaries: [{ "id": StringName, "count": int, "chance": float }]
@export var results: Array[Dictionary] = []

func can_craft_with_inventory(inventory: InventoryContainer, current_station: StationType = StationType.HAND) -> bool:
	if not inventory:
		return false
	
	# Station validation: Hand crafting recipes can be crafted at any station
	if station_required != StationType.HAND and station_required != current_station:
		return false
	
	for req in ingredients:
		var item_id: StringName = req.get("id", &"")
		var count_needed: int = int(req.get("count", 1))
		if inventory.get_item_count(item_id) < count_needed:
			return false
	
	return true

func get_max_craftable_count(inventory: InventoryContainer, current_station: StationType = StationType.HAND) -> int:
	if not inventory:
		return 0
	
	if station_required != StationType.HAND and station_required != current_station:
		return 0
	
	var max_count: int = 9999
	for req in ingredients:
		var item_id: StringName = req.get("id", &"")
		var count_needed: int = int(req.get("count", 1))
		if count_needed <= 0:
			continue
		var owned: int = inventory.get_item_count(item_id)
		var possible: int = owned / count_needed
		max_count = mini(max_count, possible)
	
	return max_count if max_count != 9999 else 0

func consume_ingredients(inventory: InventoryContainer) -> bool:
	if not can_craft_with_inventory(inventory, station_required):
		return false
	
	for req in ingredients:
		var item_id: StringName = req.get("id", &"")
		var count_needed: int = int(req.get("count", 1))
		inventory.remove_item(item_id, count_needed)
	
	return true

func refund_ingredients(inventory: InventoryContainer) -> void:
	if not inventory:
		return
	for req in ingredients:
		var item_id: StringName = req.get("id", &"")
		var count_to_refund: int = int(req.get("count", 1))
		inventory.add_item(item_id, count_to_refund)

func produce_results(inventory: InventoryContainer) -> Array[Dictionary]:
	var produced: Array[Dictionary] = []
	if not inventory:
		return produced
	
	for res in results:
		var item_id: StringName = res.get("id", &"")
		var count: int = int(res.get("count", 1))
		var chance: float = float(res.get("chance", 1.0))
		
		if randf() <= chance and count > 0:
			inventory.add_item(item_id, count)
			produced.append({ "id": item_id, "count": count })
			EventBus.item_crafted.emit(recipe_id, count)
	
	return produced
