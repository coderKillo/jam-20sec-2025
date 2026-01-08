extends Node3D

@export var car_amount = 20
@export var world: Node3D
@export var car_spawn: Node3D
@export var spawn_time: float = 1.0

@onready var ai_car_scene := preload("res://game/entities/ai/ai_car.tscn")

var _controllers: Array[AiCarController]


func _ready():
	assert(world)

	$Timer.timeout.connect(_on_spawn_timer_timeout)
	$Timer.start(spawn_time)


func _on_spawn_timer_timeout():
	if _controllers.size() >= car_amount:
		return

	# for lane_spawn in get_tree().get_nodes_in_group("car_spawn"):
	# 	_spwan_car(lane_spawn)
	for spawn in car_spawn.find_children("CarSpawner*", "CarSpawnLane"):
		_spwan_car(spawn)


func _spwan_car(lane_spawn: CarSpawnLane):
	var spawn_point := lane_spawn.get_free_spot(5.0)
	if spawn_point.origin == Vector3.ZERO:
		return

	var car := ai_car_scene.instantiate() as RayCastCar
	world.add_child(car)
	car.global_transform = spawn_point

	var controller: AiCarController = car.get_node("AiCarController")
	controller.start_position = car.global_position
	controller.target_position = car.global_position + 1000.0 * (-car.global_basis.z)
	_controllers.append(controller)
