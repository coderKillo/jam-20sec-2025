class_name CarSpawnLane
extends Node3D

@export var active := false

var _lanes: Array[RayCast3D]


func _ready():
	_lanes.assign(find_children("Lane*", "RayCast3D"))


func _process(_delta):
	for lane in _lanes:
		_get_free_spot_on_lane(lane, 5.0)


func get_free_spot(space: float) -> Transform3D:
	return _get_free_spot_on_lane(_lanes.pick_random(), space)


func _get_free_spot_on_lane(lane: RayCast3D, space: float) -> Transform3D:
	var spawn_point := lane.global_transform
	var global_target_point = lane.to_global(lane.target_position)
	var global_target_direction = lane.global_position.direction_to(global_target_point)
	spawn_point.origin = global_target_point
	spawn_point.origin -= global_target_direction * space / 2.0

	if not lane.is_colliding():
		DebugDraw3D.draw_arrow_ray(spawn_point.origin + Vector3.UP, Vector3.DOWN, 1.0, Color.YELLOW)
		return spawn_point

	var distance = global_target_point.distance_to(lane.get_collision_point())
	DebugDraw3D.draw_text(lane.global_position, "%s" % distance, 32, Color.GREEN)
	if distance > (lane.target_position.length() - space):
		DebugDraw3D.draw_arrow_ray(Vector3.UP, Vector3.DOWN, 1.0, Color.RED)
		return Transform3D()

	spawn_point.origin -= global_target_direction * distance
	DebugDraw3D.draw_arrow_ray(spawn_point.origin + Vector3.UP, Vector3.DOWN, 1.0, Color.GREEN)
	return spawn_point
