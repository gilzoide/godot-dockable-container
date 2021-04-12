tool
extends EditorPlugin

const DockableContainer = preload("res://addons/dockable_container/dockable_container.gd")
const Layout = preload("res://addons/dockable_container/layout.gd")
const LayoutInspectorPlugin = preload("res://addons/dockable_container/inspector_plugin/editor_inspector_plugin.gd")

var _layout_inspector_plugin = LayoutInspectorPlugin.new()

func _enter_tree() -> void:
	add_custom_type("DockableContainer", "Container", DockableContainer, null)
	add_custom_type("DockableContainerLayout", "Resource", Layout, null)
	add_inspector_plugin(_layout_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_layout_inspector_plugin)
	remove_custom_type("DockableContainerLayout")
	remove_custom_type("DockableContainer")
