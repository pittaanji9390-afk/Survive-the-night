class_name TestProgressionAndSkills
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_xp_and_level_up())
	results.append(_test_skill_tree_unlock())
	return results

func _test_xp_and_level_up() -> Dictionary:
	var exp_mgr: ExperienceManager = ExperienceManager.new()
	exp_mgr.current_level = 1
	exp_mgr.current_xp = 0
	exp_mgr.available_skill_points = 0
	
	# Level 1 requires 100 XP
	exp_mgr.add_xp(150)
	
	var reached_lvl_2: bool = (exp_mgr.current_level == 2)
	var remaining_xp: bool = (exp_mgr.current_xp == 50)
	var got_skill_point: bool = (exp_mgr.available_skill_points == 1)
	
	var passed: bool = reached_lvl_2 and remaining_xp and got_skill_point
	exp_mgr.free()
	return {"name": "Progression: XP & Level Up", "passed": passed, "message": "Lvl 2, 50 XP, 1 Skill Pt"}

func _test_skill_tree_unlock() -> Dictionary:
	var exp_mgr: ExperienceManager = ExperienceManager.new()
	exp_mgr.available_skill_points = 2
	
	var skill_mgr: SkillTreeManager = SkillTreeManager.new()
	skill_mgr._ready()
	
	var p_stats: PlayerStats = PlayerStats.new()
	p_stats._ready()
	var initial_hp: float = p_stats.health.get_max_value() # 100
	
	# Unlock Thick Skin (+25 HP)
	var unlocked: bool = skill_mgr.unlock_skill(&"skill_thick_skin", exp_mgr, p_stats)
	var new_hp: float = p_stats.health.get_max_value() # 125
	
	var passed: bool = unlocked and (new_hp == initial_hp + 25.0) and (exp_mgr.available_skill_points == 1)
	
	exp_mgr.free()
	skill_mgr.free()
	p_stats.free()
	return {"name": "Skills: Unlock & Stat Bonus Application", "passed": passed, "message": "Max HP boosted to %f" % new_hp}
