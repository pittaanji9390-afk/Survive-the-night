class_name BossHealthBarUI
extends Control

@onready var boss_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/BossNameLabel
@onready var health_bar: ProgressBar = $PanelContainer/MarginContainer/VBoxContainer/HealthBar

var _active_boss: NightTerrorBoss = null

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if not _active_boss:
		var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
		for b in bosses:
			if b is NightTerrorBoss and b.current_state != EnemyBase.AIState.DEAD:
				_bind_boss(b as NightTerrorBoss)
				break

func _bind_boss(boss: NightTerrorBoss) -> void:
	_active_boss = boss
	visible = true
	if boss_name_label:
		boss_name_label.text = boss.enemy_name
	if health_bar:
		health_bar.max_value = boss.max_health
		health_bar.value = boss.current_health
	
	boss.boss_health_updated.connect(_on_health_updated)
	boss.enemy_died.connect(func(_e, _k): _on_boss_defeated())

func _on_health_updated(cur: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		health_bar.value = cur

func _on_boss_defeated() -> void:
	visible = false
	_active_boss = null
	EventBus.notification_posted.emit("VICTORY!", "The Night Terror has been vanquished!", "level")
