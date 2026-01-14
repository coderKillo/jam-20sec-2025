class_name Main
extends Control

@export var world: Node3D
@export var gui: Gui
@export var follow_camera: FollowCamera
@export var player: Player

var _aim := false
var _timer_value: float = 0.0
var _progress_value: float = 0.0
var _target_object: Node3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	_update_timer(delta)
	_handle_player_input(delta)

	gui.set_timer(floori(_timer_value))
	gui.set_progress_bar(_progress_value)

	_target_object = TreeComponent.get_car_with_tree(follow_camera)
	if _target_object:
		gui.set_target_valid(true)
		if _progress_value >= 1.0:
			player.set_car(_target_object)
			_target_object = null
	else:
		gui.set_target_valid(false)


func _handle_player_input(delta: float):
	if Input.is_action_just_pressed("aim") and not _aim:
		_aim = true
		Events.player_aim.emit(true)
	if Input.is_action_just_released("aim") and _aim:
		_aim = false
		Events.player_aim.emit(false)

	if Input.is_action_pressed("fire") and _target_object:
		_progress_value += delta / Global.PLAYER_SWAP_CHARGE_TIME
	else:
		_progress_value = 0.0


func _update_timer(delta: float):
	_timer_value += delta
