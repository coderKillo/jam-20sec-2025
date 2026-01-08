extends StaticBody3D

@onready var _traffic_light_left = $TrafficLightLeft
@onready var _traffic_light_right = $TrafficLightRight
@onready var _traffic_light_front = $TrafficLightFront
@onready var _traffic_light_back = $TrafficLightBack


func _ready():
	$Timer.timeout.connect(_on_timer_timeout)

	_switch_light_lane()


func _on_timer_timeout():
	_switch_light_lane()


func _switch_light_lane():
	if _traffic_light_left.get_state() == TrafficLight.State.GREEN:
		_traffic_light_left.set_state(TrafficLight.State.RED)
		_traffic_light_right.set_state(TrafficLight.State.RED)
		await get_tree().create_timer(Global.RED_TRANSITION_TIME).timeout
		_traffic_light_front.set_state(TrafficLight.State.GREEN)
		_traffic_light_back.set_state(TrafficLight.State.GREEN)
	else:
		_traffic_light_front.set_state(TrafficLight.State.RED)
		_traffic_light_back.set_state(TrafficLight.State.RED)
		await get_tree().create_timer(Global.RED_TRANSITION_TIME).timeout
		_traffic_light_left.set_state(TrafficLight.State.GREEN)
		_traffic_light_right.set_state(TrafficLight.State.GREEN)

	$Timer.start(Global.GREEN_INTERVAL)
