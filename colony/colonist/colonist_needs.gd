class_name ColonistNeeds
extends RefCounted

signal need_depleted(need_name: StringName)
signal mental_break_triggered(break_type: MentalBreakType)

enum MentalBreakType {
	NONE,
	FOOD_BINGE,
	DAZED_WANDERING,
	BERSERK_RAGE,
	HIDE_IN_ROOM
}

var hunger: float = 100.0
var rest: float = 100.0
var recreation: float = 100.0
var comfort: float = 80.0
var social: float = 90.0

var hunger_decay_rate: float = 0.20
var rest_decay_rate: float = 0.12
var recreation_decay_rate: float = 0.10
var social_decay_rate: float = 0.08

var current_break: MentalBreakType = MentalBreakType.NONE
var break_duration_timer: float = 0.0

func update_needs(delta: float) -> void:
	if current_break != MentalBreakType.NONE:
		break_duration_timer -= delta
		if break_duration_timer <= 0.0:
			current_break = MentalBreakType.NONE
			EventBus.notification_posted.emit("Colonist Recovered", "Mental break ended.", "heart")
		return
	
	hunger = maxf(0.0, hunger - hunger_decay_rate * delta)
	rest = maxf(0.0, rest - rest_decay_rate * delta)
	recreation = maxf(0.0, recreation - recreation_decay_rate * delta)
	social = maxf(0.0, social - social_decay_rate * delta)
	
	if hunger <= 0.0: need_depleted.emit(&"hunger")
	if rest <= 0.0: need_depleted.emit(&"rest")
	
	_evaluate_mental_state()

func get_overall_morale() -> float:
	var weighted: float = (hunger * 0.35) + (rest * 0.30) + (recreation * 0.15) + (comfort * 0.10) + (social * 0.10)
	return clampf(weighted, 0.0, 100.0)

func _evaluate_mental_state() -> void:
	var morale: float = get_overall_morale()
	if morale < 20.0 and current_break == MentalBreakType.NONE:
		# Trigger mental break
		var roll: int = randi() % 3
		match roll:
			0: current_break = MentalBreakType.FOOD_BINGE
			1: current_break = MentalBreakType.DAZED_WANDERING
			2: current_break = MentalBreakType.HIDE_IN_ROOM
		
		break_duration_timer = 15.0 # 15s break duration
		mental_break_triggered.emit(current_break)
		EventBus.notification_posted.emit("MENTAL BREAK!", "A colonist suffered a mental breakdown!", "danger")

func feed(amount: float) -> void:
	hunger = minf(100.0, hunger + amount)

func sleep(amount: float) -> void:
	rest = minf(100.0, rest + amount)

func relax(amount: float) -> void:
	recreation = minf(100.0, recreation + amount)
