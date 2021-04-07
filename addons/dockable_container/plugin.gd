tool
extends EditorPlugin

const DockableContainer = preload("res://addons/dockable_container/dockable_container.gd")
const Layout = preload("res://addons/dockable_container/layout.gd")
const LayoutRoot = preload("res://addons/dockable_container/layout_root.gd")
const LayoutInspectorPlugin = preload("res://addons/dockable_container/inspector_plugin/editor_inspector_plugin.gd")

var _layout_inspector_plugin = LayoutInspectorPlugin.new()

func _enter_tree() -> void:
	add_custom_type("DockableContainer", "Container", DockableContainer, null)
	add_custom_type("DockableContainerLayoutPanel", "Resource", Layout.LayoutPanel, null)
	add_custom_type("DockableContainerLayoutSplit", "Resource", Layout.LayoutSplit, null)
	add_custom_type("DockableContainerLayoutRoot", "Resource", LayoutRoot, null)
	add_inspector_plugin(_layout_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_layout_inspector_plugin)
	remove_custom_type("DockableContainerLayoutRoot")
	remove_custom_type("DockableContainerLayoutSplit")
	remove_custom_type("DockableContainerLayoutPanel")
	remove_custom_type("DockableContainer")
