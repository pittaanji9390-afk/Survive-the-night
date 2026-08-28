class_name QuestManager
extends Node

signal quest_progress_updated(quest: QuestDefinition)
signal quest_finished(quest: QuestDefinition)

var active_quests: Array[QuestDefinition] = []
var completed_quests: Array[StringName] = []

func _ready() -> void:
	ServiceLocator.register_service(&"QuestManager", self)
	_setup_default_quests()
	
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.item_crafted.connect(_on_item_crafted)
	EventBus.entity_died.connect(_on_entity_died)
	EventBus.day_started.connect(_on_day_started)

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"QuestManager")

func _setup_default_quests() -> void:
	_add_quest(&"quest_wood", "Lumberjack's First Steps", "Chop trees to gather 10 Wood logs for base construction.",
		QuestDefinition.QuestType.GATHER, &"wood", 10, 40)

	_add_quest(&"quest_axe", "Primitive Tooling", "Craft a sturdy Stone Axe at your crafting station.",
		QuestDefinition.QuestType.CRAFT, &"craft_stone_axe", 1, 50)

	_add_quest(&"quest_survive_night", "Survive the Night", "Endure through your first night against nocturnal horrors.",
		QuestDefinition.QuestType.SURVIVE_NIGHTS, &"night", 1, 100)

	_add_quest(&"quest_slay_zombies", "Cull the Swarm", "Defeat 5 nocturnal zombies threatening your shelter.",
		QuestDefinition.QuestType.KILL_ENEMIES, &"Zombie", 5, 80)

func _add_quest(id: StringName, title: String, desc: String, q_type: QuestDefinition.QuestType, target: StringName, count: int, xp: int) -> void:
	var q: QuestDefinition = QuestDefinition.new()
	q.quest_id = id
	q.title = title
	q.description = desc
	q.quest_type = q_type
	q.target_id = target
	q.target_count = count
	q.reward_xp = xp
	active_quests.append(q)

func _on_item_picked_up(item_id: StringName, amount: int) -> void:
	_check_progress(QuestDefinition.QuestType.GATHER, item_id, amount)

func _on_item_crafted(recipe_id: StringName, count: int) -> void:
	_check_progress(QuestDefinition.QuestType.CRAFT, recipe_id, count)

func _on_entity_died(entity: Node2D, _killer: Node2D) -> void:
	if entity is EnemyBase:
		_check_progress(QuestDefinition.QuestType.KILL_ENEMIES, StringName(entity.name), 1)

func _on_day_started(_day: int) -> void:
	_check_progress(QuestDefinition.QuestType.SURVIVE_NIGHTS, &"night", 1)

func _check_progress(q_type: QuestDefinition.QuestType, target: StringName, amount: int) -> void:
	for i in range(active_quests.size() - 1, -1, -1):
		var q: QuestDefinition = active_quests[i]
		if q.quest_type == q_type and (q.target_id == target or q.target_id == &"any"):
			var just_completed: bool = q.add_progress(amount)
			quest_progress_updated.emit(q)
			
			if just_completed:
				_complete_quest(q, i)

func _complete_quest(q: QuestDefinition, index: int) -> void:
	active_quests.remove_at(index)
	completed_quests.append(q.quest_id)
	
	var exp_mgr: ExperienceManager = ServiceLocator.get_service(&"ExperienceManager") as ExperienceManager
	if exp_mgr and q.reward_xp > 0:
		exp_mgr.add_xp(q.reward_xp)
	
	EventBus.quest_completed.emit(q.quest_id)
	EventBus.notification_posted.emit("QUEST COMPLETED!", q.title, "quest")
	GameLogger.info("QuestManager", "Completed quest: %s" % q.title)
	quest_finished.emit(q)
