class_name TreeComponent
extends Node3D

@onready var _tree: Node3D = $Tree


func has_tree() -> bool:
	return _tree.visible


func set_tree(enable: bool):
	_tree.visible = enable


static func get_tree_component(node: Node3D):
	var tree = node.get_node("TreeComponent") as TreeComponent
	if tree:
		return tree
	return null
