tool
extends EditorPlugin

const DockableContainerTree = preload("res://addons/dockable_container/dockable_container_tree.gd")

func _enter_tree() -> void:
	add_custom_type("DockableContainerTree", "Resource", DockableContainerTree, null)
	add_custom_type("DockableContainerTreeLeaf", "Resource", DockableContainerTree.Leaf, null)


func _exit_tree() -> void:
	remove_custom_type("DockableContainerTreeLeaf")
	remove_custom_type("DockableContainerTree")
