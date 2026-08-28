class_name TestNPCAndTrading
extends RefCounted

func run_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(_test_npc_database_lookup())
	results.append(_test_trading_exchange())
	return results

func _test_npc_database_lookup() -> Dictionary:
	var npc: NPCDefinition = NPCDatabase.get_npc(&"npc_elder")
	var passed: bool = (npc != null) and (npc.dialogue_lines.size() >= 2) and (npc.trade_offers.size() >= 1)
	return {"name": "NPC: Database Lookup & Dialogue", "passed": passed, "message": "Elder Roderick database record valid"}

func _test_trading_exchange() -> Dictionary:
	var inv: InventoryContainer = InventoryContainer.new(10)
	inv.add_item(&"wood", 16)
	
	var trade_offer: Dictionary = {
		"cost_id": &"wood",
		"cost_count": 8,
		"reward_id": &"seed_wheat",
		"reward_count": 3
	}
	
	# Execute barter exchange
	inv.remove_item(trade_offer.cost_id, trade_offer.cost_count)
	inv.add_item(trade_offer.reward_id, trade_offer.reward_count)
	
	var wood_left: int = inv.get_item_count(&"wood")
	var seeds_got: int = inv.get_item_count(&"seed_wheat")
	
	var passed: bool = (wood_left == 8) and (seeds_got == 3)
	inv.free()
	return {"name": "Trading: Barter Resource Exchange", "passed": passed, "message": "Wood left: %d, Seeds: %d" % [wood_left, seeds_got]}
