class_name TrafficLight
extends Node3D

enum State { RED, GREEN, TRANSITION }

@onready var _body: StaticBody3D = $StaticBody

@onready var _red: Node3D = $RedLight
@onready var _yellow: Node3D = $YellowLight
@onready var _green: Node3D = $GreenLight

@onready var _red_transition_timer: Timer = $RedTimer
@onready var _green_transition_timer: Timer = $GreenTimer

var _current_state: State = State.RED


func _ready():
	_red_transition_timer.timeout.connect(_end_red_transition)
	_green_transition_timer.timeout.connect(_end_green_transition)


func set_state(state: State):
	if state == _current_state:
		return

	if state == State.RED and _current_state == State.GREEN:
		_start_red_transition()
	if state == State.GREEN and _current_state == State.RED:
		_start_green_transition()


func get_state() -> State:
	return _current_state


func _start_red_transition():
	_current_state = State.TRANSITION

	_red.hide()
	_yellow.show()
	_green.hide()

	_red_transition_timer.start(Global.RED_TRANSITION_TIME)


func _start_green_transition():
	_current_state = State.TRANSITION

	_red.show()
	_yellow.show()
	_green.hide()

	_green_transition_timer.start(Global.GREEN_TRANSITION_TIME)


func _end_red_transition():
	_current_state = State.RED

	_red.show()
	_yellow.hide()
	_green.hide()

	_block_street(true)


func _end_green_transition():
	_current_state = State.GREEN

	_red.hide()
	_yellow.hide()
	_green.show()

	_block_street(false)


func _block_street(blocked: bool):
	if blocked:
		_body.global_rotation_degrees.x = 0
	else:
		_body.global_rotation_degrees.x = -90
