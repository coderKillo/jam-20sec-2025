class_name TreeComponent
extends Node3D

@onready var _tree: Node3D = $Tree
@onready var area: Area3D = $Area3D


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


static func get_car_with_tree(camera: FollowCamera) -> Node3D:
	var target_object := camera.get_aim_target(Global.PLAYER_SWAP_DISTANCE)
	if TreeComponent.node_has_tree(target_object):
		return target_object

	var tree_area := camera.get_aim_target(Global.PLAYER_SWAP_DISTANCE, false, 0x08)
	if (
		tree_area
		and is_instance_of(tree_area.get_parent(), TreeComponent)
		and tree_area.get_parent().has_tree()
	):
		return tree_area.get_parent()

	return null
