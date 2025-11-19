class_name CarBody2D
extends CharacterBody2D

signal speed_changed(factor: float)
signal acceleration_changed(factor: float)

@export var max_engine_power = 1200  # Forward acceleration force.
@export var max_speed_reverse = 250
@export var max_steering_degrees = 15  # Amount that front wheel turns, in degrees
@export var friction = 0.9
@export var drag = 0.0015
@export var brakes = 4.0
@export var slip_speed = 400  # Speed where traction is reduced
@export var traction_fast = 0.1  # High-speed traction
@export var traction_slow = 0.7  # Low-speed traction
@export var wheel_base = 70  # Distance from front to rear wheel
@export var paused := false

var _highest_measured_speed = 0


class CarInput:
	var steering := 0.0  # -1.0 (left) to 1.0 (right)
	var acceleration := 0.0  # -1.0 (reverse) to 1.0 (accelerate)
	var braking := false  # True if brakes are engaged


var _car_input := CarInput.new()


func _init():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING


func provide_input(input: CarInput):
	_car_input = input


func _physics_process(delta):
	if paused:
		return

	_car_input.steering = clamp(_car_input.steering, -1.0, 1.0)
	_car_input.acceleration = clamp(_car_input.acceleration, -1.0, 1.0)

	# Base steering wheel angle and acceleration
	var steer_angle = _car_input.steering * deg_to_rad(max_steering_degrees)
	var acceleration = _car_input.acceleration * transform.x * max_engine_power

	# Apply friction
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * -friction
	var drag_force = velocity * velocity.length() * -drag
	if velocity.length() < 100:
		friction_force *= 3
	acceleration += drag_force + friction_force

	# Calculate steering
	var rear_wheel = position - transform.x * wheel_base / 2.0 + velocity * delta
	var front_wheel = (
		position + transform.x * wheel_base / 2.0 + velocity.rotated(steer_angle) * delta
	)
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	if _car_input.braking:
		traction = 0.01

	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	# Update the physics engine
	rotation = new_heading.angle()
	velocity += acceleration * delta
	move_and_slide()

	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is CarBody2D:
			var push_force = (150.0 * _speed_factor()) + 10.0
			c.get_collider().velocity += velocity.normalized() * push_force

	speed_changed.emit(_speed_factor())
	acceleration_changed.emit(abs(acceleration))


func _speed_factor() -> float:
	var speed = velocity.length()
	if speed > _highest_measured_speed:
		_highest_measured_speed = speed
	return speed / _highest_measured_speed if _highest_measured_speed > 0 else 0
