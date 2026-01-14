extends Node3D

@export var world: Node3D
@export var player: Player

@export_category("Settings")
@export var car_amount = 20
@export var spawn_time: float = 1.0
@export var spawn_distance_in_view: float = 100.0
@export var spawn_distance_out_of_view: float = 10.0
@export var spawn_angle_to_player: float = 80.0

#TODO: optimize spawn by pooling
#TODO: imporve ratio

@onready var car_db: Array = [
	{spawn_ratio = 1, scene = preload("res://game/entities/ai/vehicle/ambulance.tscn")},
	{spawn_ratio = 3, scene = preload("res://game/entities/ai/vehicle/delivery.tscn")},
	{spawn_ratio = 1, scene = preload("res://game/entities/ai/vehicle/firetruck.tscn")},
	{spawn_ratio = 2, scene = preload("res://game/entities/ai/vehicle/garbagetruck.tscn")},
	{spawn_ratio = 5, scene = preload("res://game/entities/ai/vehicle/police.tscn")},
	{spawn_ratio = 10, scene = preload("res://game/entities/ai/vehicle/sedan.tscn")},
	{spawn_ratio = 5, scene = preload("res://game/entities/ai/vehicle/sedan_sport.tscn")},
	{spawn_ratio = 10, scene = preload("res://game/entities/ai/vehicle/sport.tscn")},
	{spawn_ratio = 15, scene = preload("res://game/entities/ai/vehicle/suv.tscn")},
	{spawn_ratio = 5, scene = preload("res://game/entities/ai/vehicle/suv_luxus.tscn")},
	{spawn_ratio = 3, scene = preload("res://game/entities/ai/vehicle/taxi.tscn")},
	{spawn_ratio = 3, scene = preload("res://game/entities/ai/vehicle/truck.tscn")},
	{spawn_ratio = 3, scene = preload("res://game/entities/ai/vehicle/truck_flat.tscn")},
	{spawn_ratio = 5, scene = preload("res://game/entities/ai/vehicle/van.tscn")},
]

var _controllers: Array[AiCarController]
var _max_spawn_ratio: int = 0
var _cumulative_spawn_ratio: Array[int] = []


func _ready():
	assert(world)
	assert(player)

	$Timer.timeout.connect(_on_spawn_timer_timeout)
	$Timer.start(spawn_time)

	for entry in car_db:
		_max_spawn_ratio += entry.spawn_ratio
		_cumulative_spawn_ratio.append(_max_spawn_ratio)


func _on_spawn_timer_timeout():
	_despawn_cars()

	if _controllers.size() >= car_amount:
		return

	for lane_spawn in get_tree().get_nodes_in_group("car_spawn"):
		if (
			_in_player_view(lane_spawn)
			and (
				_distance_to_player(lane_spawn) < spawn_distance_in_view
				or _distance_to_player(lane_spawn) > Global.PLAYER_VIEW_DISTANCE
			)
		):
			_spwan_car(lane_spawn)


func _in_player_view(node: Node3D) -> bool:
	var direction = player.global_position.direction_to(node.global_position)
	var car_forward = -player.global_basis.z

	# Project onto XZ plane
	direction.y = 0.0
	car_forward.y = 0.0
	direction = direction.normalized()
	car_forward = car_forward.normalized()

	var angle = rad_to_deg(direction.angle_to(car_forward))
	return angle < spawn_angle_to_player


func _distance_to_player(node: Node3D) -> float:
	return player.global_position.distance_to(player.global_position)


func _despawn_cars():
	for i in range(_controllers.size() - 1, -1, -1):
		var controller := _controllers[i] as AiCarController
		var car := controller.car
		if (
			(_in_player_view(car) and _distance_to_player(car) < spawn_distance_in_view)
			or _distance_to_player(car) < spawn_distance_out_of_view
		):
			continue
		car.queue_free()
		_controllers.remove_at(i)


func _spwan_car(lane_spawn: CarSpawnLane):
	var spawn_point := lane_spawn.get_free_spot(5.0)
	if spawn_point.origin == Vector3.ZERO:
		return

	var car := _pick_car().instantiate()
	world.add_child(car)
	car.global_transform = spawn_point

	var tree: TreeComponent = TreeComponent.get_tree_component(car)
	if tree:
		#TODO: add probability to spawn tree
		tree.set_tree(randi() % 2 == 0)

	var controller := AiCarController.get_controller(car)
	controller.start_position = car.global_position
	controller.target_position = car.global_position + 1000.0 * (-car.global_basis.z)
	_controllers.append(controller)


func _pick_car() -> PackedScene:
	var random_number := randi_range(0, _max_spawn_ratio)
	for i in range(_cumulative_spawn_ratio.size()):
		if random_number < _cumulative_spawn_ratio[i]:
			return car_db[i].scene
	return car_db.pick_random().scene
