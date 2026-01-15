@tool
extends Node3D  # or Node

@export var apply_now: bool = false:
	set(value):
		if value:
			_apply_shader_to_all()
		apply_now = false  # reset

var shader_mat: ShaderMaterial = preload("res://game/materials/snow_covered_buildings.tres")


func _apply_shader_to_all() -> void:
	if not Engine.is_editor_hint():
		return

	_apply_recursive(self)


func _apply_recursive(node: Node) -> void:
	if node is MeshInstance3D and node.mesh:
		var mi := node as MeshInstance3D
		# apply to all surfaces
		var surface_count := mi.mesh.get_surface_count()
		for i in surface_count:
			mi.set_surface_override_material(i, shader_mat)

	for child in node.get_children():
		if child.scene_file_path != "":
			self.set_editable_instance(child, true)
		_apply_recursive(child)
