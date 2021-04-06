tool
extends EditorPlugin

const DockableContainerTreeBranch = preload("res://addons/dockable_container/dockable_container_tree.gd")

func _enter_tree() -> void:
	add_custom_type("DockableContainerBranch", "Resource", DockableContainerTreeBranch, null)
	add_custom_type("DockableContainerLeaf", "Resource", DockableContainerTreeBranch.Leaf, null)


func _exit_tree() -> void:
	remove_custom_type("DockableContainerLeaf")
	remove_custom_type("DockableContainerBranch")
