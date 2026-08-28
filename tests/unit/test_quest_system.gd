class_name TestQuestSystem
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_quest_progress_and_completion())
	return results

func _test_quest_progress_and_completion() -> Dictionary:
	var q: QuestDefinition = QuestDefinition.new()
	q.quest_id = &"test_chop"
	q.target_count = 5
	q.current_count = 0
	
	var fin_1: bool = q.add_progress(3)
	var count_mid: int = q.current_count
	
	var fin_2: bool = q.add_progress(2)
	var count_end: int = q.current_count
	
	var passed: bool = (not fin_1) and (count_mid == 3) and fin_2 and (count_end == 5) and q.is_completed
	return {"name": "Quests: Objective Tracking & Completion", "passed": passed, "message": "Quest completed at 5/5"}
