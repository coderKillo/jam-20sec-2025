class_name RayCastCar
extends RigidBody3D

@export var wheels: Array[RayCastWheel]

@export var max_speed := 20.0
@export var acceleration := 600.0
@export var acceleration_curve: Curve

var motor_input := 0.0
var turn_input := 0.0
var brake := false


func _physics_process(_delta):
	for wheel in wheels:
		wheel.turn(turn_input)
		if brake and wheel.is_motor:
			wheel.wheel_traction.x = 0.1
		else:
			wheel.wheel_traction.x = 0.7

		wheel.process_car_physic(motor_input, _get_wheel_accleration(wheel.forward_velocity()))

	if wheels.any(func(wheel): return wheel.is_grounded):
		center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		center_of_mass = Vector3.DOWN * 1.0
	else:
		center_of_mass = Vector3.ZERO


func _get_wheel_accleration(speed: float) -> float:
	return acceleration * acceleration_curve.sample_baked(speed / max_speed)


# calculate the velocity of a single point in the rigid body with following formular:
# vpoint = vlinear + vangular cross (p - x)
# p is the point on the rigid body
# x is the center of mass of the object
func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)
