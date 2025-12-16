class_name AiCarController
extends Node3D

@export var distance_to_goal_tolerance: float = 1.0
@export_range(0.0, 1.0) var speed_min: float
@export_range(0.0, 1.0) var speed_max: float

@onready var car: RayCastCar = get_parent()

var target_checkpoint: Checkpoint
var speed: float

var _intrests: Array[RayCast3D]
var _distance_checker: RayCast3D


func _ready():
	assert(car)

	speed = randf_range(speed_min, speed_max)

	_intrests.assign(find_children("IntrestVector*", "RayCast3D"))
	_distance_checker = get_node("DistanceChecker")


func _process(_delta):
	car.motor_input = 0.0

	if is_on_goal_position():
		return

	var input = _get_input()
	car.turn_input = input.y
	car.motor_input = input.x


func is_on_goal_position() -> bool:
	return (
		global_position.distance_to(target_checkpoint.global_position) < distance_to_goal_tolerance
	)


# return car input, x = motor, y = steering
func _get_input() -> Vector2:
	var input := Vector2.ZERO

	var to_target: Vector3 = (
		(target_checkpoint.global_position - car.global_transform.origin).normalized()
	)

	# calculate where to drive
	var intrest_vector := Vector3.ZERO
	for intrest in _intrests:
		var intrest_forward = -intrest.global_basis.z
		var partially_intrest = intrest_forward.dot(to_target) * intrest_forward

		if intrest.is_colliding():
			continue

		intrest_vector += partially_intrest

	input.y = _get_steering(intrest_vector.normalized())

	# TODO: refactor
	if _distance_checker.is_colliding():
		var collider_velocity := Vector3.ZERO
		var collider := _distance_checker.get_collider() as RigidBody3D
		if collider:
			collider_velocity = collider.linear_velocity

		var car_forwad = -car.global_basis.z
		var car_forward_speed = car_forwad.dot(car.linear_velocity)
		var target_speed = car_forwad.dot(collider_velocity) - car_forward_speed

		input.x = speed * (clampf(target_speed, -1.0, 1.0))
	else:
		input.x = speed

	DebugDraw3D.draw_arrow_ray(
		car.global_position, -car.global_basis.z, input.x * 10.0, Color.RED, 0.1, true
	)

	return input


func _get_steering(to_target: Vector3):
	var forward: Vector3 = -global_transform.basis.z

	# Project onto XZ plane
	to_target.y = 0.0
	forward.y = 0.0
	to_target = to_target.normalized()
	forward = forward.normalized()

	# Signed angle around Y axis
	var angle: float = -atan2(forward.cross(to_target).y, forward.dot(to_target))  # radians, left -, right +
	var steering: float = clamp(rad_to_deg(angle) / car.turn_degrees, -1.0, 1.0)  # normaliz and clamp angle
	return steering
