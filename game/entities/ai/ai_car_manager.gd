extends Node3D

@export var car_amount = 100
@export var world: Node3D

@onready var ai_car_scene = preload("res://game/entities/ai/ai_car.tscn")

var _controllers: Array[AiCarController]
var _checkpoints: Array[Checkpoint]


func _ready():
	assert(world)

	for i in range(car_amount):
		var car := ai_car_scene.instantiate() as RayCastCar
		world.add_child(car)
		car.global_position = Vector3(-200, 10, -200)
		car.global_position -= (Vector3(floori(i / 20.0), 0, i % 20) * 3)

	for controller in get_tree().get_nodes_in_group("ai_car_controller"):
		if controller is AiCarController:
			_controllers.append(controller)

	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		if checkpoint is Checkpoint:
			_checkpoints.append(checkpoint)

	if not _checkpoints.is_empty():
		for controller in _controllers:
			controller.target_checkpoint = _checkpoints.front()


func _process(_delta):
	for controller in _controllers:
		if not controller.is_on_goal_position():
			continue
		controller.target_checkpoint = controller.target_checkpoint.linked_points.pick_random()
