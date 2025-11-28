extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


func _physics_process(_delta):
	if Input.is_action_just_pressed("brake"):
		apply_impulse(Vector3.UP * 3, Vector3(-0.5, 0.25, -1.0))
