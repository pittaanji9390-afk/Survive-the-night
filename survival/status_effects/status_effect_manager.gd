class_name StatusEffectManager
extends Node

signal effect_applied(effect: StatusEffect)
signal effect_removed(effect: StatusEffect)
signal effects_updated()

var active_effects: Array[StatusEffect] = []
var _player_stats: PlayerStats = null

func _ready() -> void:
	ServiceLocator.register_service(&"StatusEffectManager", self)
	var parent_player: Node2D = get_parent() as Node2D
	if parent_player:
		_player_stats = parent_player.get_node_or_null("PlayerStats") as PlayerStats

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"StatusEffectManager")

func _process(delta: float) -> void:
	if active_effects.is_empty():
		return
	
	if not _player_stats:
		var parent_player: Node2D = get_parent() as Node2D
		if parent_player:
			_player_stats = parent_player.get_node_or_null("PlayerStats") as PlayerStats
		if not _player_stats:
			return
	
	var changed: bool = false
	for i in range(active_effects.size() - 1, -1, -1):
		var eff: StatusEffect = active_effects[i]
		var is_finished: bool = eff.update_effect(delta, _player_stats)
		if is_finished:
			effect_removed.emit(eff)
			active_effects.remove_at(i)
			changed = true
	
	if changed:
		effects_updated.emit()

func apply_effect(effect_template: StatusEffect) -> void:
	if not effect_template:
		return
	
	# Check if already active -> refresh duration
	for eff in active_effects:
		if eff.effect_id == effect_template.effect_id:
			eff.remaining_time = maxf(eff.remaining_time, effect_template.duration_sec)
			effects_updated.emit()
			return
	
	var new_instance: StatusEffect = effect_template.duplicate_effect()
	active_effects.append(new_instance)
	effect_applied.emit(new_instance)
	effects_updated.emit()
	
	var badge: String = "buff" if new_instance.is_buff else "warn"
	EventBus.notification_posted.emit("Status Effect", new_instance.display_name, badge)
	GameLogger.info("StatusEffect", "Applied effect: %s" % new_instance.display_name)

func remove_effect(effect_id: StringName) -> void:
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].effect_id == effect_id:
			var removed: StatusEffect = active_effects[i]
			active_effects.remove_at(i)
			effect_removed.emit(removed)
			effects_updated.emit()
			return

func has_effect(effect_id: StringName) -> bool:
	for eff in active_effects:
		if eff.effect_id == effect_id:
			return true
	return false

func clear_all_effects() -> void:
	active_effects.clear()
	effects_updated.emit()
