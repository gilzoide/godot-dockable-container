tool
extends EditorPlugin

const DockableContainerTree = preload("res://addons/dockable_container/dockable_container_tree.gd")
const DockableContainerTreeBranch = preload("res://addons/dockable_container/dockable_container_tree_branch.gd")

func _enter_tree() -> void:
	add_custom_type("DockableContainerTreeNode", "Resource", DockableContainerTree, null)
	add_custom_type("DockableContainerBranch", "DockableContainerTree", DockableContainerTreeBranch, null)
	add_custom_type("DockableContainerLeaf", "DockableContainerTree", DockableContainerTreeBranch.Leaf, null)


func _exit_tree() -> void:
	remove_custom_type("DockableContainerLeaf")
	remove_custom_type("DockableContainerBranch")
	remove_custom_type("DockableContainerTreeNode")
