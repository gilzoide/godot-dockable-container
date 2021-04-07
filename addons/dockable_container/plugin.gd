tool
extends EditorPlugin

const Layout = preload("res://addons/dockable_container/layout.gd")
const LayoutInspectorPlugin = preload("res://addons/dockable_container/inspector_plugin/editor_inspector_plugin.gd")

var _layout_inspector_plugin = LayoutInspectorPlugin.new()

func _enter_tree() -> void:
	add_custom_type("DockableContainerLayoutPanel", "Resource", Layout.LayoutPanel, null)
	add_custom_type("DockableContainerLayoutSplit", "Resource", Layout.LayoutSplit, null)
	add_inspector_plugin(_layout_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_layout_inspector_plugin)
	remove_custom_type("DockableContainerLayoutSplit")
	remove_custom_type("DockableContainerLayoutPanel")
