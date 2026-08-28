class_name CraftingQueue
extends Node

signal queue_updated()
signal crafting_progress(current_recipe: CraftingRecipe, progress_ratio: float, remaining_time: float)
signal crafting_completed(recipe: CraftingRecipe)
signal crafting_cancelled(recipe: CraftingRecipe)

class CraftJob:
	var recipe: CraftingRecipe
	var remaining_time: float
	var total_time: float
	var batch_count: int
	
	func _init(p_recipe: CraftingRecipe, p_batch: int = 1) -> void:
		recipe = p_recipe
		total_time = p_recipe.craft_time_sec
		remaining_time = total_time
		batch_count = p_batch

var queue: Array[CraftJob] = []
var _inventory: InventoryContainer = null

func _ready() -> void:
	_inventory = get_parent().get_node_or_null("InventoryContainer") as InventoryContainer

func _process(delta: float) -> void:
	if queue.is_empty():
		return
	
	if not _inventory:
		_inventory = get_parent().get_node_or_null("InventoryContainer") as InventoryContainer
		if not _inventory:
			return
	
	var current_job: CraftJob = queue[0]
	current_job.remaining_time -= delta
	
	var ratio: float = 1.0 - clampf(current_job.remaining_time / current_job.total_time, 0.0, 1.0)
	crafting_progress.emit(current_job.recipe, ratio, maxf(0.0, current_job.remaining_time))
	
	if current_job.remaining_time <= 0.0:
		_finish_single_craft(current_job)

func queue_recipe(recipe: CraftingRecipe, count: int = 1, current_station: CraftingRecipe.StationType = CraftingRecipe.StationType.HAND) -> bool:
	if not recipe or count <= 0:
		return false
	
	if not _inventory:
		_inventory = get_parent().get_node_or_null("InventoryContainer") as InventoryContainer
		if not _inventory:
			return false
	
	var max_possible: int = recipe.get_max_craftable_count(_inventory, current_station)
	var craft_count: int = mini(count, max_possible)
	if craft_count <= 0:
		GameLogger.info("CraftingQueue", "Not enough resources to craft %s" % recipe.display_name)
		return false
	
	# Consume ingredients upfront for the entire batch
	for i in range(craft_count):
		recipe.consume_ingredients(_inventory)
	
	queue.append(CraftJob.new(recipe, craft_count))
	queue_updated.emit()
	GameLogger.info("CraftingQueue", "Queued %d x %s" % [craft_count, recipe.display_name])
	return true

func cancel_job(index: int) -> bool:
	if index < 0 or index >= queue.size():
		return false
	
	var job: CraftJob = queue[index]
	if _inventory:
		for i in range(job.batch_count):
			job.recipe.refund_ingredients(_inventory)
	
	queue.remove_at(index)
	crafting_cancelled.emit(job.recipe)
	queue_updated.emit()
	GameLogger.info("CraftingQueue", "Cancelled craft of %s (refunded ingredients)" % job.recipe.display_name)
	return true

func is_crafting() -> bool:
	return not queue.is_empty()

func get_current_job() -> CraftJob:
	return queue[0] if not queue.is_empty() else null

func _finish_single_craft(job: CraftJob) -> void:
	if _inventory:
		job.recipe.produce_results(_inventory)
	
	job.batch_count -= 1
	crafting_completed.emit(job.recipe)
	
	if job.batch_count > 0:
		job.remaining_time = job.total_time
	else:
		queue.remove_at(0)
	
	queue_updated.emit()
