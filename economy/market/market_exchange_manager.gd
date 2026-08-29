class_name MarketExchangeManager
extends Node

const MarketCommodityClass = preload("res://economy/market/market_commodity.gd")

signal market_tick_completed(tick_number: int)
signal trade_executed(item_id: StringName, is_buy: bool, amount: int, total_cost: float)

var commodities: Dictionary = {}
var player_portfolio: Dictionary = {} # item_id -> quantity owned
var player_cash: float = 500.0
var total_market_ticks: int = 0

func _ready() -> void:
	ServiceLocator.register_service(&"MarketExchangeManager", self)
	_setup_default_commodities()

func _exit_tree() -> void:
	ServiceLocator.unregister_service(&"MarketExchangeManager")

func _setup_default_commodities() -> void:
	_add_commodity(&"wheat", "Grain Wheat", 8.0, 1200.0, 1200.0, 0.04)
	_add_commodity(&"iron_ore", "Iron Ore", 20.0, 800.0, 800.0, 0.06)
	_add_commodity(&"gold_ingot", "Gold Bullion", 80.0, 300.0, 300.0, 0.08)
	_add_commodity(&"mythril_ore", "Mythril Ore", 150.0, 150.0, 150.0, 0.12)
	_add_commodity(&"crude_oil", "Crude Oil", 45.0, 600.0, 600.0, 0.09)
	_add_commodity(&"herb", "Medicinal Herb", 15.0, 500.0, 500.0, 0.05)

func _add_commodity(id: StringName, name: String, base_p: float, supply: float, demand: float, vol: float) -> void:
	var c = MarketCommodityClass.new(id, name, base_p, supply, demand, vol)
	commodities[id] = c

func get_commodity(id: StringName):
	return commodities.get(id, null)

func tick_market() -> void:
	total_market_ticks += 1
	for id in commodities:
		var c = commodities[id]
		var noise: float = randf_range(-1.0, 1.0)
		c.update_market_tick(noise)
	
	market_tick_completed.emit(total_market_ticks)

func buy_commodity(id: StringName, amount: int) -> bool:
	if not commodities.has(id) or amount <= 0:
		return false
	
	var c = commodities[id]
	var total_cost: float = c.current_price * amount
	if player_cash >= total_cost:
		player_cash -= total_cost
		player_portfolio[id] = player_portfolio.get(id, 0) + amount
		c.execute_trade(true, amount)
		trade_executed.emit(id, true, amount, total_cost)
		EventBus.notification_posted.emit("Market Trade", "Bought %d x %s for $%.2f" % [amount, c.display_name, total_cost], "coin")
		return true
	return false

func sell_commodity(id: StringName, amount: int) -> bool:
	if not commodities.has(id) or amount <= 0:
		return false
	
	var owned: int = player_portfolio.get(id, 0)
	if owned >= amount:
		var c = commodities[id]
		var total_gain: float = c.current_price * amount
		player_cash += total_gain
		player_portfolio[id] = owned - amount
		c.execute_trade(false, amount)
		trade_executed.emit(id, false, amount, total_gain)
		EventBus.notification_posted.emit("Market Trade", "Sold %d x %s for $%.2f" % [amount, c.display_name, total_gain], "coin")
		return true
	return false
