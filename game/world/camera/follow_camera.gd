extends Node3D

@export_category("Follow Camera Settings")
# Must be a vehicle body
@export var follow_target: Node3D
@export_range(0.0, 10.0) var camera_height: float = 2.0
@export_range(1.0, 20.0) var camera_distance: float = 5.0
@export_range(0.0, 10.0) var rotation_damping = 1.0
@export_range(0.0, 1.0) var camera_rotation_sense = 0.3

#locals
@onready var pivot: Node3D = $Pivot
@onready var springarm: SpringArm3D = $Pivot/SpringArm3D


func _ready() -> void:
	pivot.position.y = camera_height
	springarm.spring_length = camera_distance

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position = follow_target.global_position
	var target_horizontal_direction = follow_target.global_basis.z.normalized()
	var desired_basis = Basis.looking_at(-target_horizontal_direction)
	global_basis = global_basis.slerp(desired_basis, rotation_damping * delta)

	pivot.rotation.y = move_toward(pivot.rotation.y, 0.0, delta)


func _input(event):
	if event is InputEventMouseMotion:
		pivot.rotate_y(deg_to_rad(-event.relative.x * camera_rotation_sense))

	if event.is_action_pressed("ui_cancel"):  # 'ui_cancel' is typically Escape
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
