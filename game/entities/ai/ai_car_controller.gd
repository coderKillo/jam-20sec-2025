class_name AiCarController
extends Node3D

@export var distance_checker: RayCast3D
@export var distance_to_goal_tolerance: float = 1.0
@export_range(0.0, 1.0) var speed_min: float
@export_range(0.0, 1.0) var speed_max: float

@onready var car: RayCastCar = get_parent()

var target_position: Vector3
var speed: float


func _ready():
	assert(distance_checker)
	assert(car)

	speed = randf_range(speed_min, speed_max)


func _process(_delta):
	car.motor_input = 0.0

	if is_on_goal_position():
		return

	var input = _get_input()
	car.turn_input = input.y
	car.motor_input = input.x


func is_on_goal_position() -> bool:
	return global_position.distance_to(target_position) < distance_to_goal_tolerance


# return car input, x = motor, y = steering
func _get_input() -> Vector2:
	var input := Vector2.ZERO

	input.y = _get_steering()
	if not distance_checker.is_colliding():
		input.x = speed

	return input


func _get_steering():
	var to_target: Vector3 = (target_position - car.global_transform.origin).normalized()
	var forward: Vector3 = -global_transform.basis.z

	# Project onto XZ plane
	to_target.y = 0.0
	forward.y = 0.0
	to_target = to_target.normalized()
	forward = forward.normalized()

	DebugDraw3D.draw_arrow_ray(car.global_position, to_target, 10.0, Color.RED, 0.1, true)
	DebugDraw3D.draw_arrow_ray(car.global_position, forward, 10.0, Color.BLUE, 0.1, true)

	# Signed angle around Y axis
	var angle: float = -atan2(forward.cross(to_target).y, forward.dot(to_target))  # radians, left -, right +
	var steering: float = clamp(rad_to_deg(angle) / car.turn_degrees, -1.0, 1.0)  # normaliz and clamp angle
	return steering
