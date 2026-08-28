class_name StatusEffectsUI
extends Control

@onready var container_hbox: HBoxContainer = $HBoxContainer

var _status_mgr: StatusEffectManager = null

func _ready() -> void:
	_bind_manager()

func _process(_delta: float) -> void:
	_bind_manager()
	_update_ui()

func _bind_manager() -> void:
	if not _status_mgr:
		var player: Node2D = ServiceLocator.get_service(&"Player") as Node2D
		if player:
			_status_mgr = player.get_node_or_null("StatusEffectManager") as StatusEffectManager

func _update_ui() -> void:
	if not _status_mgr or not container_hbox:
		return
	
	for child in container_hbox.get_children():
		child.queue_free()
	
	for eff in _status_mgr.active_effects:
		var panel: PanelContainer = PanelContainer.new()
		var lbl: Label = Label.new()
		lbl.text = "%s (%.0fs)" % [eff.display_name, maxf(0.0, eff.remaining_time)]
		lbl.theme_override_font_sizes.font_size = 11
		lbl.modulate = Color(0.4, 1.2, 0.5, 1.0) if eff.is_buff else Color(1.3, 0.4, 0.4, 1.0)
		panel.add_child(lbl)
		container_hbox.add_child(panel)
