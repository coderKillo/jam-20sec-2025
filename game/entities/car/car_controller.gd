extends VehicleBody3D

@export_category("Car Settings")
@export var max_steer : float = 0.45
@export var max_torque : float = 300.0
@export var max_brake_force : float = 1.0
@export var max_wheel_rpm : float = 600.0
@export var steer_speed = 2.0

@onready var driving_wheels : Array[VehicleWheel3D] = [$WheelBackLeft,$WheelBackRight]
@onready var steering_wheels : Array[VehicleWheel3D] = [$WheelFrontLeft,$WheelFrontRight]


func _physics_process(delta: float) -> void:
	$CameraArm.position = position

	var player_input = Vector2(Input.get_axis("right","left"), Input.get_axis("down","up"))
	var rpm = (abs($WheelBackLeft.get_rpm()) - abs($WheelBackRight.get_rpm())) / 2.0
	var torque = player_input.y * max_torque * (1.0 - rpm / max_wheel_rpm)

	engine_force = torque
	steering = lerp(steering, player_input.x * max_steer, steer_speed * delta)

	if player_input.y == 0:
		brake = 2



func going_forward() -> bool:
	var relative_speed : float = basis.z.dot(linear_velocity.normalized())
	if relative_speed > 0.01:
		return true
	else:
		return false
	
