extends Node3D

@export var car_amount = 100
@export var world: Node3D

@onready var ai_car_scene = preload("res://game/entities/ai/ai_car.tscn")

var _controllers: Array[AiCarController]
var _spawn_points: Array[Node3D]
var _spawn_timer: float = 0.0


func _ready():
	assert(world)


func _process(_delta):
	if _controllers.size() >= car_amount:
		return
	if _spawn_timer < 3.0:
		_spawn_timer += _delta
		return
	_spawn_timer = 0.0

	for point in get_tree().get_nodes_in_group("car_spawn"):
		_spwan_car(point.global_transform)


func _spwan_car(car_transform: Transform3D):
	var car := ai_car_scene.instantiate() as RayCastCar
	world.add_child(car)
	car.global_transform = car_transform

	var controller: AiCarController = car.get_node("AiCarController")
	controller.start_position = car.global_position
	controller.target_position = car.global_position + 1000.0 * (-car.global_basis.z)
	_controllers.append(controller)
