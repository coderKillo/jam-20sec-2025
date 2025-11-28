class_name RayCastWheel
extends RayCast3D

@export var is_motor := false
@export var is_turning := false

@export_category("Wheel Settings")
@export var wheel_radius := 0.4
@export var wheel_turn_degrees := 25.0
@export var wheel_turn_speed := 100.0
@export var wheel_traction := Vector2(0.7, 0.05)

@export_category("Spring Settings")
@export var spring_strength := 5000.0
@export var spring_damping := 120.0
@export var spring_rest_len := 0.5
@export var spring_over_extend := 0.2

@onready var model: Node3D = get_child(0)
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var car: RayCastCar = get_parent()

var is_grounded = false


func _ready():
	target_position.y = -(spring_rest_len + wheel_radius + spring_over_extend)
	assert(car, "Set RayCastCar as parent of RayCastWheel")


func turn(turn_input: float):
	if not is_turning:
		return

	var turn_delta = wheel_turn_speed * get_physics_process_delta_time()
	if turn_input:
		var angle = rotation_degrees.y + turn_input * turn_delta
		rotation_degrees.y = clampf(angle, -wheel_turn_degrees, wheel_turn_degrees)
	else:
		rotation_degrees.y = move_toward(rotation_degrees.y, 0, turn_delta)


func process_car_physic(motor_input: float, acceleration: float):
	force_raycast_update()

	if not is_colliding():
		is_grounded = false
		return

	is_grounded = true

	var force_position = wheel_global_position() - car.global_position
	var contact_point = get_collision_point()
	var contact_point_velocity = car._get_point_velocity(contact_point)

	var spring_length = global_position.distance_to(contact_point) - wheel_radius
	var spring_force = spring_strength * (spring_rest_len - spring_length)

	var relative_velocity = up().dot(contact_point_velocity)
	var spring_damping_force = relative_velocity * spring_damping

	var force = up() * (spring_force - spring_damping_force)

	car.apply_force(force, force_position)

	if motor_input and is_motor:
		var force_vector = forward() * motor_input * acceleration
		force_vector = _project_vector_to_plane(force_vector, get_collision_normal())
		car.apply_force(force_vector, force_position)

	var gravity_force_per_wheel = (gravity * car.mass) / car.wheels.size()

	# x traction
	var side_velocity = right().dot(velocity())
	var side_force = -right() * side_velocity * wheel_traction.x * gravity_force_per_wheel
	# y traction
	var forward_force = -forward() * forward_velocity() * wheel_traction.y * gravity_force_per_wheel

	car.apply_force(side_force, force_position)
	car.apply_force(forward_force, force_position)

	model.position.y = -spring_length
	model.rotate_x(-forward_velocity() * get_physics_process_delta_time() / wheel_radius)


func velocity() -> Vector3:
	return car._get_point_velocity(global_position)


func forward_velocity() -> float:
	return forward().dot(velocity())


func forward() -> Vector3:
	return -global_basis.z


func up() -> Vector3:
	return global_basis.y


func right() -> Vector3:
	return global_basis.x


func wheel_global_position() -> Vector3:
	return global_position - (up() * spring_rest_len)


# calculates the projected vector to a plane using the plane normal
# useful for projecting forces to a plane
func _project_vector_to_plane(vector: Vector3, plane_normal: Vector3) -> Vector3:
	return vector - plane_normal * vector.dot(plane_normal)
