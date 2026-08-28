class_name CardBattleGame
extends RefCounted

signal turn_started(turn: int)
signal hero_damaged(hp: float, block: float)
signal enemy_damaged(hp: float)
signal battle_resolved(victory: bool)

var hero_hp: float = 80.0
var hero_max_hp: float = 80.0
var hero_block: float = 0.0
var energy: int = 3
var max_energy: int = 3

var enemy_hp: float = 60.0
var enemy_max_hp: float = 60.0
var enemy_block: float = 0.0
var enemy_intent_damage: float = 12.0

var draw_pile: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var turn_number: int = 0

func start_battle() -> void:
	_build_starter_deck()
	start_turn()

func _build_starter_deck() -> void:
	draw_pile.clear()
	for i in 4: draw_pile.append({ "name": "Strike", "cost": 1, "type": "attack", "value": 6 })
	for i in 4: draw_pile.append({ "name": "Defend", "cost": 1, "type": "skill", "value": 5 })
	draw_pile.append({ "name": "Fireball", "cost": 2, "type": "attack", "value": 14 })
	draw_pile.shuffle()

func start_turn() -> void:
	turn_number += 1
	energy = max_energy
	hero_block = 0.0
	_draw_hand(5)
	turn_started.emit(turn_number)

func _draw_hand(count: int) -> void:
	for i in count:
		if draw_pile.is_empty():
			draw_pile.append_array(discard_pile)
			discard_pile.clear()
			draw_pile.shuffle()
		
		if not draw_pile.is_empty():
			hand.append(draw_pile.pop_back())

func play_card(card_idx: int) -> bool:
	if card_idx < 0 or card_idx >= hand.size():
		return false
	
	var card: Dictionary = hand[card_idx]
	if energy < card.cost:
		return false
	
	energy -= card.cost
	hand.remove_at(card_idx)
	discard_pile.append(card)
	
	match card.type:
		"attack":
			var dmg: float = card.value
			if enemy_block > 0:
				var absorbed: float = minf(enemy_block, dmg)
				enemy_block -= absorbed
				dmg -= absorbed
			enemy_hp = maxf(0.0, enemy_hp - dmg)
			enemy_damaged.emit(enemy_hp)
			if enemy_hp <= 0.0:
				battle_resolved.emit(true)
		"skill":
			hero_block += card.value
	
	return true

func end_turn() -> void:
	discard_pile.append_array(hand)
	hand.clear()
	
	# Enemy attack
	if enemy_hp > 0.0:
		var incoming: float = enemy_intent_damage
		if hero_block > 0:
			var absorbed: float = minf(hero_block, incoming)
			hero_block -= absorbed
			incoming -= absorbed
		hero_hp = maxf(0.0, hero_hp - incoming)
		hero_damaged.emit(hero_hp, hero_block)
		if hero_hp <= 0.0:
			battle_resolved.emit(false)
			return
	
	start_turn()
