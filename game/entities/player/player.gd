extends RayCastCar


func _process(_delta):
	motor_input = Input.get_axis("down", "up")
	turn_input = Input.get_axis("right", "left")
	brake = Input.is_action_pressed("brake")
