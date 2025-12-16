class_name Checkpoint
extends Node3D

@export var linked_points: Array[Checkpoint]


func _process(_delta):
	for point in linked_points:
		DebugDraw3D.draw_arrow_ray(
			global_position,
			global_position.direction_to(point.global_position),
			10.0,
			Color.GREEN_YELLOW,
			0.1,
			true
		)
