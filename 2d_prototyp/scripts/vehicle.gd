class_name Vehicle
extends RigidBody2D

@export var grip = 1.0
@export var steering_speed = 0.5
@export var steering_speed_decay = 0.1
# true: steering wheels return to their forward position
# false: steering wheels remain at their current angle
@export var center_steering = true
@export var air_resistance = 0.1
@export var push_back_on_collision = 0.1
@export var health = 10

var wheels: Array[Wheel] = []

var _car_input := CarBody2D.CarInput.new()


func _ready():
	for child in get_children():
		if child is Wheel:
			wheels.append(child)
			child.vehicle = self
			child.grip = grip
			child.steering_speed = steering_speed
			child.center_steering = center_steering


func provide_input(input: CarBody2D.CarInput):
	_car_input = input


func hit():
	if health <= 0:
		return
	health -= 1
	print(name, ":", health)

	if health <= 0:
		_dead()


func _physics_process(_delta):
	# sends other cars flying
	for c in get_colliding_bodies():
		if c is Vehicle:
			c.apply_impulse(
				(linear_velocity - c.linear_velocity) * -push_back_on_collision,
				c.global_position - global_position
			)
			c.hit()

	var drive_input = _car_input.acceleration
	for wheel in wheels:
		wheel.drive(drive_input)

	var steering_input = _car_input.steering
	steering_input /= 0.01 * steering_speed_decay * linear_velocity.length() + 1.0
	for wheel in wheels:
		wheel.steer(steering_input)
		wheel.apply_lateral_forces()

	_air_resistance()


func _air_resistance():
	var vel = 0.005 * linear_velocity
	apply_central_impulse(-air_resistance * vel)


func _dead():
	$Explosion.explode()
