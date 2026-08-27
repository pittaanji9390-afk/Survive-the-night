class_name GameEventBus
extends Node

# --- Game State Signals ---
signal game_state_changed(old_state: int, new_state: int)
signal game_paused(is_paused: bool)

# --- Time & Environment Signals ---
signal time_tick(hour: int, minute: int)
signal day_phase_changed(phase: int)
signal day_started(day_number: int)
signal night_started(night_number: int)
signal weather_changed(weather_type: int)

# --- Player Signals ---
signal player_spawned(player: Node2D)
signal player_died()
signal player_respawned()
signal player_stat_changed(stat_name: StringName, current_value: float, max_value: float)
signal player_interacted_with(target: Node)
signal player_leveled_up(new_level: int, skill_points: int)

# --- Inventory & Item Signals ---
signal item_picked_up(item_id: StringName, amount: int)
signal inventory_slot_updated(slot_index: int, item_id: StringName, quantity: int)
signal hotbar_selection_changed(index: int, item_id: StringName)
signal item_crafted(recipe_id: StringName, count: int)

# --- Combat Signals ---
signal entity_damaged(target: Node2D, attacker: Node2D, amount: float, is_critical: bool)
signal entity_died(entity: Node2D, killer: Node2D)
signal screen_shake_requested(trauma_amount: float)

# --- Building Signals ---
signal building_mode_toggled(is_building: bool)
signal structure_placed(structure_id: StringName, grid_pos: Vector2i)
signal structure_destroyed(structure_node: Node2D)

# --- Wave & Survival Signals ---
signal wave_countdown_started(time_remaining_sec: float)
signal wave_started(wave_number: int, enemy_count: int)
signal wave_enemy_killed(remaining_count: int)
signal wave_completed(wave_number: int)

# --- Quest & Dialogue Signals ---
signal quest_accepted(quest_id: StringName)
signal quest_step_updated(quest_id: StringName, step_index: int)
signal quest_completed(quest_id: StringName)
signal dialogue_started(npc_id: StringName)
signal dialogue_ended(npc_id: StringName)

# --- UI & Settings Signals ---
signal notification_posted(title: String, message: String, icon_type: String)
signal debug_mode_toggled(is_active: bool)
