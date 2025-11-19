extends Area2D

@export var explosion_power = 50.0
@export var fire_once = true

var _fired: bool = false
var _firing: bool = false


func explode():
	if fire_once and _fired:
		return

	print("boom")
	_fired = true
	_firing = true


func _physics_process(_delta):
	if not _firing:
		return
	_firing = false
	print("pang")
	for body in get_overlapping_bodies():
		if body is Vehicle:
			var direction: Vector2 = body.global_position - global_position
			body.apply_central_impulse(direction.normalized() * explosion_power)
