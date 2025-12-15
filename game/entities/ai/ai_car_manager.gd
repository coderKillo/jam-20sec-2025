extends Node3D

var _controllers: Array[AiCarController]


func _ready():
	for controller in get_tree().get_nodes_in_group("ai_car_controller"):
		if controller is AiCarController:
			_controllers.append(controller)


func _process(_delta):
	for controller in _controllers:
		if controller.distance_checker.is_colliding():
			controller.car.motor_input = 0.0
		else:
			controller.car.motor_input = 0.4
