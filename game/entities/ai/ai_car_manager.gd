extends Node3D

var _controllers: Array[AiCarController]


func _ready():
	for controller in get_tree().get_nodes_in_group("ai_car_controller"):
		if controller is AiCarController:
			_controllers.append(controller)
