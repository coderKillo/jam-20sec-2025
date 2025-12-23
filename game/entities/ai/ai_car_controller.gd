class_name AiCarController
extends Node3D

@export var distance_to_goal_tolerance: float = 1.0
@export var distance_look_ahead: float = 5.0
@export_range(0.0, 1.0) var speed_min: float
@export_range(0.0, 1.0) var speed_max: float

@onready var car: RayCastCar = get_parent()

var start_position := Vector3.ZERO
var target_position := Vector3.FORWARD * 100.0
var speed: float

var _interests: Array[RayCast3D]
var _distance_checker: RayCast3D


func _ready():
	assert(car)

	speed = randf_range(speed_min, speed_max)

	_interests.assign(find_children("IntrestVector*", "RayCast3D"))
	_distance_checker = get_node("DistanceChecker")


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

	var drive_to: Vector3 = _get_closest_point_on_lane()
	var to_target: Vector3 = car.global_position.direction_to(drive_to)

	DebugDraw3D.draw_arrow_ray(drive_to + Vector3.UP, Vector3.DOWN, 1.0, Color.RED)

	# calculate where to drive
	var interest_vector := Vector3.ZERO
	for interest in _interests:
		var interest_forward = -interest.global_basis.z
		var partially_interest = to_target.dot(interest_forward) * interest_forward

		if interest.is_colliding():
			continue

		interest_vector += partially_interest

	input.y = _get_steering(interest_vector.normalized())
	input.x = _get_speed()

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


func _get_speed() -> float:
	if not _distance_checker.is_colliding():
		return speed

	var collider_velocity := Vector3.ZERO
	var collider := _distance_checker.get_collider() as RigidBody3D
	if collider:
		collider_velocity = collider.linear_velocity

	var car_forward = -car.global_basis.z
	var car_forward_speed = car_forward.dot(car.linear_velocity)
	var target_speed = car_forward.dot(collider_velocity) - car_forward_speed

	return speed * (clampf(target_speed, -1.0, 1.0))


func _get_closest_point_on_lane() -> Vector3:
	var closest_point := Geometry3D.get_closest_point_to_segment(
		car.global_position, start_position, target_position
	)
	var lane_direction := start_position.direction_to(target_position)
	var look_ahead_point := closest_point + distance_look_ahead * lane_direction
	return look_ahead_point
