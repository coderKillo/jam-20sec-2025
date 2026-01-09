extends Node3D

@export var world: Node3D

@export_category("Settings")
@export var car_amount = 20
@export var spawn_time: float = 1.0
@export var spawn_distance_in_view: float = 100.0
@export var spawn_distance_out_of_view: float = 10.0
@export var spawn_angle_to_player: float = 80.0

@export_category("Database")
@export var car_db: Array[PackedScene]

var _controllers: Array[AiCarController]
var _player_car: RayCastCar


func _ready():
	assert(world)

	$Timer.timeout.connect(_on_spawn_timer_timeout)
	$Timer.start(spawn_time)

	_player_car = world.get_node("PlayerCar") as RayCastCar
	assert(_player_car)


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
	var direction = _player_car.global_position.direction_to(node.global_position)
	var car_forward = -_player_car.global_basis.z

	# Project onto XZ plane
	direction.y = 0.0
	car_forward.y = 0.0
	direction = direction.normalized()
	car_forward = car_forward.normalized()

	var angle = rad_to_deg(direction.angle_to(car_forward))
	return angle < spawn_angle_to_player


func _distance_to_player(node: Node3D) -> float:
	return _player_car.global_position.distance_to(node.global_position)


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

	var car := car_db.pick_random().instantiate() as RayCastCar
	world.add_child(car)
	car.global_transform = spawn_point

	var controller: AiCarController = car.get_node("AiCarController")
	controller.start_position = car.global_position
	controller.target_position = car.global_position + 1000.0 * (-car.global_basis.z)
	_controllers.append(controller)
