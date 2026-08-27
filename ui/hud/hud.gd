class_name HUDController
extends Control

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/HealthBar
@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/StaminaBar
@onready var hunger_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsContainer/HungerBar
@onready var time_label: Label = $TopRightContainer/TimeVBox/TimeLabel
@onready var day_label: Label = $TopRightContainer/TimeVBox/DayLabel
@onready var phase_label: Label = $TopRightContainer/TimeVBox/PhaseLabel
@onready var notification_label: Label = $CenterNotification/NotificationLabel

var _target_health: float = 100.0
var _target_stamina: float = 100.0
var _target_hunger: float = 100.0

var _notification_timer: float = 0.0

func _ready() -> void:
	EventBus.player_stat_changed.connect(_on_player_stat_changed)
	EventBus.time_tick.connect(_on_time_tick)
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_phase_changed.connect(_on_day_phase_changed)
	EventBus.notification_posted.connect(_on_notification_posted)
	
	_update_time_ui()

func _process(delta: float) -> void:
	if health_bar:
		health_bar.value = lerpf(health_bar.value, _target_health, 10.0 * delta)
	if stamina_bar:
		stamina_bar.value = lerpf(stamina_bar.value, _target_stamina, 15.0 * delta)
	if hunger_bar:
		hunger_bar.value = lerpf(hunger_bar.value, _target_hunger, 10.0 * delta)
	
	if _notification_timer > 0.0:
		_notification_timer -= delta
		if _notification_timer <= 0.0 and notification_label:
			notification_label.visible = false

func _on_player_stat_changed(stat_name: StringName, current_value: float, max_value: float) -> void:
	var ratio: float = (current_value / max_value) * 100.0 if max_value > 0.0 else 0.0
	match stat_name:
		&"Health":
			_target_health = ratio
		&"Stamina":
			_target_stamina = ratio
		&"Hunger":
			_target_hunger = ratio

func _on_time_tick(_hour: int, _minute: int) -> void:
	_update_time_ui()

func _on_day_started(_day: int) -> void:
	_update_time_ui()

func _on_day_phase_changed(_phase: int) -> void:
	_update_time_ui()

func _update_time_ui() -> void:
	if time_label:
		time_label.text = TimeManager.get_time_string()
	if day_label:
		day_label.text = "Day %d" % TimeManager.current_day
	if phase_label:
		phase_label.text = TimeManager.get_phase_name()

func _on_notification_posted(_title: String, message: String, _icon_type: String) -> void:
	if notification_label:
		notification_label.text = message
		notification_label.visible = true
		_notification_timer = 3.5
