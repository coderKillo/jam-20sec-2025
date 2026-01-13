class_name TreeComponent
extends Node3D

@onready var _tree: Node3D = $Tree


func has_tree() -> bool:
	return _tree.visible


func set_tree(enable: bool):
	_tree.visible = enable


static func get_tree_component(node: Node3D) -> TreeComponent:
	var tree = node.get_node_or_null("TreeComponent") as TreeComponent
	if tree:
		return tree
	return null


static func node_has_tree(node) -> bool:
	if not node:
		return false
	var tree_component := TreeComponent.get_tree_component(node)
	if not tree_component:
		return false
	return tree_component.has_tree()
