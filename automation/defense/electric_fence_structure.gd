class_name ElectricFenceStructure
extends StructureInstance

@export var shock_damage: float = 30.0
@export var shock_cooldown_sec: float = 1.0

var power_comp: PowerComponent = null
var _shock_timer: float = 0.0

func _ready() -> void:
	structure_id = &"electric_fence"
	super._ready()
	power_comp = PowerComponent.new()
	power_comp.power_type = PowerComponent.PowerType.CONSUMER
	power_comp.wattage = 15.0
	add_child(power_comp)

func _process(delta: float) -> void:
	if _shock_timer > 0.0:
		_shock_timer -= delta
	
	if not power_comp or not power_comp.is_powered or _shock_timer > 0.0 or not is_inside_tree():
		return
	
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if is_instance_valid(e) and e is EnemyBase:
			var enemy: EnemyBase = e as EnemyBase
			if enemy.current_state != EnemyBase.AIState.DEAD and global_position.distance_to(enemy.global_position) <= 24.0:
				_shock_enemy(enemy)
				break

func _shock_enemy(enemy: EnemyBase) -> void:
	_shock_timer = shock_cooldown_sec
	enemy.take_damage(shock_damage, self, true)
	EventBus.screen_shake_requested.emit(0.2)
	EventBus.notification_posted.emit("Defense Grid", "Electric fence shocked %s for 30 DMG!" % enemy.enemy_name, "spark")
