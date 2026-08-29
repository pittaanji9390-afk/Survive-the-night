class_name TestComplexSimulations
extends RefCounted

const MarketExchangeManagerClass = preload("res://economy/market/market_exchange_manager.gd")
const FireGridManagerClass = preload("res://simulation/fire/fire_grid_manager.gd")
const FluidCellularAutomataClass = preload("res://simulation/fluids/fluid_cellular_automata.gd")

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_market_trading_and_pricing())
	results.append(_test_fire_spread_propagation())
	results.append(_test_fluid_downward_gravity_flow())
	return results

func _test_market_trading_and_pricing() -> Dictionary:
	var exchange = MarketExchangeManagerClass.new()
	exchange._ready()
	
	var initial_cash: float = exchange.player_cash # 500.0
	
	# Buy 10 wheat
	var bought: bool = exchange.buy_commodity(&"wheat", 10)
	var cash_after_buy: float = exchange.player_cash
	var owned_after_buy: int = exchange.player_portfolio.get(&"wheat", 0) # 10
	
	# Sell 5 wheat
	var sold: bool = exchange.sell_commodity(&"wheat", 5)
	var owned_after_sell: int = exchange.player_portfolio.get(&"wheat", 0) # 5
	var cash_after_sell: float = exchange.player_cash
	
	var passed: bool = bought and sold and (owned_after_buy == 10) and (owned_after_sell == 5) and (cash_after_buy < initial_cash) and (cash_after_sell > cash_after_buy)
	exchange.free()
	return {"name": "Market: Dynamic Commodity Trading & Portfolio Cash", "passed": passed, "message": "Bought 10 and sold 5 wheat with dynamic price execution"}

func _test_fire_spread_propagation() -> Dictionary:
	var fire_grid = FireGridManagerClass.new()
	fire_grid._ready()
	
	# Create 2 adjacent wooden cells
	var c1 = Vector2i(0, 0)
	var c2 = Vector2i(1, 0)
	fire_grid.register_cell(c1, 0.8, 100.0)
	fire_grid.register_cell(c2, 0.8, 100.0)
	
	# Ignite c1
	fire_grid.ignite_cell(c1)
	var c1_burning: bool = fire_grid.grid[c1].is_burning
	
	# Run simulation step -> heat spreads to c2 and auto-ignites it
	fire_grid.update_fire_step(4.0)
	var c2_burning: bool = fire_grid.grid[c2].is_burning
	
	var passed: bool = c1_burning and c2_burning
	fire_grid.free()
	return {"name": "Fire: Cellular Combustion & Heat Propagation", "passed": passed, "message": "Fire propagated from (0,0) to (1,0)"}

func _test_fluid_downward_gravity_flow() -> Dictionary:
	var fluid_sim = FluidCellularAutomataClass.new(5, 5)
	
	# Add 1.0 volume of water at top (2, 0)
	fluid_sim.add_liquid(Vector2i(2, 0), 1.0, 0.8)
	
	# Run 1 step -> fluid flows down to (2, 1)
	fluid_sim.simulate_step()
	
	var top_vol: float = fluid_sim.grid[Vector2i(2, 0)].volume
	var below_vol: float = fluid_sim.grid[Vector2i(2, 1)].volume
	
	var passed: bool = (below_vol > 0.0) and (top_vol < 1.0)
	return {"name": "Fluids: Hydraulic Cellular Pressure & Gravity Fall", "passed": passed, "message": "Water flowed down: top=%f, below=%f" % [top_vol, below_vol]}
