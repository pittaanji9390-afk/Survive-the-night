class_name MarketCommodity
extends RefCounted

signal price_updated(item_id: StringName, current_price: float, change_pct: float)

var item_id: StringName = &"wheat"
var display_name: String = "Wheat"
var base_price: float = 10.0
var current_price: float = 10.0
var supply: float = 1000.0
var demand: float = 1000.0
var volatility: float = 0.05
var price_history: Array[float] = []

func _init(id: StringName, name: String, base_p: float, init_supply: float = 1000.0, init_demand: float = 1000.0, vol: float = 0.05) -> void:
	item_id = id
	display_name = name
	base_price = base_p
	current_price = base_p
	supply = init_supply
	demand = init_demand
	volatility = vol
	price_history.append(current_price)

func update_market_tick(random_noise: float = 0.0) -> float:
	var old_price: float = current_price
	var ratio: float = demand / maxf(1.0, supply)
	var target_price: float = base_price * ratio
	
	# Apply mean reversion + volatility shock
	var delta: float = (target_price - current_price) * 0.15 + (current_price * random_noise * volatility)
	current_price = maxf(1.0, current_price + delta)
	
	price_history.append(current_price)
	if price_history.size() > 30:
		price_history.pop_front()
	
	var change_pct: float = ((current_price - old_price) / old_price) * 100.0
	price_updated.emit(item_id, current_price, change_pct)
	return current_price

func execute_trade(buy_order: bool, volume: int) -> float:
	if buy_order:
		demand += volume * 1.2
		supply = maxf(10.0, supply - volume)
	else:
		supply += volume * 1.2
		demand = maxf(10.0, demand - volume)
	
	return update_market_tick()
