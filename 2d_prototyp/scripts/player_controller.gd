extends Node2D

@export var car: Node2D

var input := CarBody2D.CarInput.new()


func _physics_process(_delta):
	input.steering = Input.get_axis("left", "right")
	input.acceleration = Input.get_axis("down", "up")
	input.braking = Input.is_action_pressed("brake")

	car.provide_input(input)
