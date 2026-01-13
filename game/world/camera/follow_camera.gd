class_name FollowCamera
extends Node3D

@export_category("Follow Camera Settings")
# Must be a vehicle body
@export var follow_target: Node3D
@export_range(0.0, 10.0) var camera_height: float = 2.0
@export_range(1.0, 20.0) var camera_distance: float = 5.0
@export_range(1.0, 20.0) var camera_look_ahead: float = 5.0
@export_range(0.0, 10.0) var rotation_damping = 1.0
@export_range(0.0, 1.0) var camera_rotation_sense = 0.005
@export var min_pitch := -60.0
@export var max_pitch := 45.0

@export_category("Aim Camera Settings")
@export var camera_aim_offset: float = 2.0
@export var camera_distance_aim: float = 5.0
@export var camera_look_ahead_aim: float = 5.0
@export_range(0.0, 10.0) var camera_aim_damping = 1.0

#locals
@onready var pivot: Node3D = $Pivot
@onready var springarm: SpringArm3D = $Pivot/SpringArm3D
@onready var camera: Camera3D = $Pivot/SpringArm3D/Camera3D

var _yaw := 0.0
var _pitch := 0.0
var _look_ahead := 0.0
var _aim := false


func get_aim_target(distance: float) -> Node3D:
	var screen_center := get_viewport().get_visible_rect().size * 0.5
	var ray_origin: Vector3 = camera.project_ray_origin(screen_center)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(screen_center) * distance

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := space_state.intersect_ray(query)
	if result.size() > 0:
		return result.collider
	return null


func _ready() -> void:
	pivot.position.y = camera_height
	Events.player_aim.connect(_on_player_aim)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position = follow_target.global_position

	var target_forward_direction = -follow_target.global_basis.z.normalized()
	var desired_basis = Basis.looking_at(target_forward_direction)
	global_basis = global_basis.slerp(desired_basis, rotation_damping * delta)

	if _aim:
		_set_camera(camera_aim_offset, camera_distance_aim, camera_look_ahead_aim, delta)
	else:
		_set_camera(0, camera_distance, camera_look_ahead, delta)

	camera.look_at(pivot.global_position - pivot.global_basis.z * _look_ahead)


func _input(event):
	if event is InputEventMouseMotion:
		_update_camera_rotation(event.relative)


func _update_camera_rotation(mouse_delta: Vector2) -> void:
	_yaw -= mouse_delta.x * camera_rotation_sense
	_pitch -= mouse_delta.y * camera_rotation_sense
	_pitch = clamp(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

	pivot.rotation = Vector3(_pitch, _yaw, 0.0)


func _on_player_aim(aim: bool) -> void:
	_aim = aim


func _set_camera(offset: float, distance: float, look_ahead: float, delta: float) -> void:
	pivot.position.x = lerp(pivot.position.x, -offset, delta * camera_aim_damping)
	springarm.spring_length = lerp(springarm.spring_length, distance, delta * camera_aim_damping)
	_look_ahead = lerp(_look_ahead, look_ahead, delta * camera_aim_damping)
