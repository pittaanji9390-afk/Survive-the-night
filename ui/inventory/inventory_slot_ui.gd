class_name InventorySlotUI
extends Button

signal slot_left_clicked(slot_index: int)
signal slot_right_clicked(slot_index: int)

@export var slot_index: int = 0

@onready var icon_rect: TextureRect = $IconRect
@onready var count_label: Label = $CountLabel
@onready var rarity_border: Panel = $RarityBorder

var item_id: StringName = &""
var quantity: int = 0

func _ready() -> void:
	custom_minimum_size = Vector2(44, 44)
	gui_input.connect(_on_gui_input)
	update_slot(&"", 0, 0)

func update_slot(p_id: StringName, p_qty: int, _dur: int = 0) -> void:
	item_id = p_id
	quantity = p_qty
	
	if item_id == &"" or quantity <= 0:
		if icon_rect:
			icon_rect.visible = false
		if count_label:
			count_label.visible = false
		if rarity_border:
			rarity_border.modulate = Color(0.3, 0.35, 0.4, 0.4)
		tooltip_text = ""
		return
	
	var def: ItemDefinition = ItemDatabase.get_item(item_id)
	if not def:
		return
	
	if icon_rect:
		icon_rect.visible = true
		if def.icon:
			icon_rect.texture = def.icon
		else:
			icon_rect.texture = preload("res://assets/tiles/dirt_tile.png")
	
	if count_label:
		count_label.visible = quantity > 1
		count_label.text = str(quantity)
	
	if rarity_border:
		rarity_border.modulate = def.get_rarity_color()
	
	tooltip_text = "%s\n[%s]\n%s\nWeight: %.1fkg | Value: %d" % [
		def.name,
		ItemDefinition.Category.keys()[def.category],
		def.description,
		def.weight * float(quantity),
		def.value * quantity
	]

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_left_clicked.emit(slot_index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slot_right_clicked.emit(slot_index)
