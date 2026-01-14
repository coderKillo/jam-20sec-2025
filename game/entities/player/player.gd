class_name Player
extends Node3D

@export var start_car: RayCastCar

var car: RayCastCar


func _ready():
	assert(start_car)
	set_car(start_car)


func _process(delta):
	if not car:
		return
	global_transform = lerp(global_transform, car.global_transform, 5.0 * delta)
	car.motor_input = Input.get_axis("down", "up")
	car.turn_input = Input.get_axis("left", "right")
	car.brake = Input.is_action_pressed("brake")


func set_car(new_car: RayCastCar):
	if car:
		AiCarController.get_controller(car).active = true

	car = new_car
	AiCarController.get_controller(car).active = false
