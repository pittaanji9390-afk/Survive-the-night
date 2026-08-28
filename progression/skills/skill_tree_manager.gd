class_name SkillTreeManager
extends Node

signal skill_unlocked(skill_id: StringName)

var unlocked_skills: Array[StringName] = []
var _skills: Dictionary = {}

func _ready() -> void:
	ServiceLocator.register_service(&"SkillTreeManager", self)
	_populate_skill_tree()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"SkillTreeManager")

func is_skill_unlocked(skill_id: StringName) -> bool:
	return unlocked_skills.has(skill_id)

func can_unlock_skill(skill_id: StringName, exp_mgr: ExperienceManager) -> bool:
	if is_skill_unlocked(skill_id):
		return false
	
	var node: SkillNode = get_skill(skill_id)
	if not node:
		return false
	
	if exp_mgr and exp_mgr.available_skill_points < node.point_cost:
		return false
	
	for req in node.prerequisites:
		if not is_skill_unlocked(req):
			return false
	
	return true

func unlock_skill(skill_id: StringName, exp_mgr: ExperienceManager, player_stats: PlayerStats = null) -> bool:
	if not can_unlock_skill(skill_id, exp_mgr):
		return false
	
	var node: SkillNode = get_skill(skill_id)
	if exp_mgr:
		exp_mgr.available_skill_points -= node.point_cost
	
	unlocked_skills.append(skill_id)
	_apply_skill_bonuses(node, player_stats)
	skill_unlocked.emit(skill_id)
	EventBus.notification_posted.emit("Skill Mastered", "Learned: " + node.title, "skill")
	GameLogger.info("SkillTree", "Unlocked skill: %s" % node.title)
	return true

func _apply_skill_bonuses(node: SkillNode, stats: PlayerStats) -> void:
	if not stats:
		return
	if node.stat_bonuses.has("health"):
		stats.health.modify_base(node.stat_bonuses["health"])
	if node.stat_bonuses.has("speed"):
		stats.speed.modify_base(node.stat_bonuses["speed"])
	if node.stat_bonuses.has("stamina"):
		stats.stamina.modify_base(node.stat_bonuses["stamina"])

func get_skill(id: StringName) -> SkillNode:
	return _skills.get(id, null)

func get_all_skills() -> Array[SkillNode]:
	var list: Array[SkillNode] = []
	for k in _skills:
		list.append(_skills[k])
	return list

func serialize() -> Array[String]:
	var list: Array[String] = []
	for s in unlocked_skills:
		list.append(String(s))
	return list

func deserialize(data: Array) -> void:
	unlocked_skills.clear()
	for s in data:
		unlocked_skills.append(StringName(s))

func _populate_skill_tree() -> void:
	_register(&"skill_thick_skin", "Thick Skin", "Increases maximum health by +25 HP.",
		SkillNode.BranchType.SURVIVAL, 1, [], { "health": 25.0 })

	_register(&"skill_swift_stride", "Swift Stride", "Increases base movement and sprint speed by +20.",
		SkillNode.BranchType.SURVIVAL, 1, [&"skill_thick_skin"], { "speed": 20.0 })

	_register(&"skill_deep_lungs", "Iron Lungs", "Increases maximum stamina pool by +30.",
		SkillNode.BranchType.SURVIVAL, 1, [&"skill_thick_skin"], { "stamina": 30.0 })

	_register(&"skill_heavy_hitter", "Heavy Hitter", "Increases all melee damage output.",
		SkillNode.BranchType.WARRIOR, 1, [], { "damage": 6.0 })

	_register(&"skill_blade_master", "Blade Master", "Increases weapon attack speed and critical strike strike chance.",
		SkillNode.BranchType.WARRIOR, 2, [&"skill_heavy_hitter"], { "damage": 10.0 })

	_register(&"skill_architect", "Master Architect", "Enhances base structure durability by +50%.",
		SkillNode.BranchType.BUILDER, 1, [], {})

func _register(id: StringName, title: String, desc: String, branch: SkillNode.BranchType, cost: int, prereqs: Array[StringName], bonuses: Dictionary) -> void:
	var s: SkillNode = SkillNode.new()
	s.skill_id = id
	s.title = title
	s.description = desc
	s.branch = branch
	s.point_cost = cost
	s.prerequisites = prereqs
	s.stat_bonuses = bonuses
	_skills[id] = s
