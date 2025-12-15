extends RayCastCar


func _process(_delta):
	motor_input = Input.get_axis("down", "up")
	turn_input = Input.get_axis("left", "right")
	brake = Input.is_action_pressed("brake")
