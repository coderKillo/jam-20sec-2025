class_name Gui
extends Control

@export var _timer: Label
@export var _progress_bar: ProgressBar
@export var _crosshair: TextureRect


func _ready() -> void:
	Events.player_aim.connect(_on_player_aim)
	_crosshair.hide()


func set_timer(value: int) -> void:
	var formatted_value = "%02d:%02d" % [(value % 3600) / 60.0, value % 60]
	_timer.text = formatted_value


func set_progress_bar(value: float) -> void:
	value = clamp(value, 0.0, 1.0)
	_progress_bar.value = value
	_progress_bar.visible = value > 0.0


func set_target_valid(valid: bool) -> void:
	_crosshair.get_node("Valid").visible = valid


func _on_player_aim(aim: bool) -> void:
	_crosshair.visible = aim
