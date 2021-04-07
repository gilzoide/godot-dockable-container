extends EditorInspectorPlugin

const DockableContainer = preload("res://addons/dockable_container/dockable_container.gd")
const LayoutEditorProperty = preload("res://addons/dockable_container/inspector_plugin/layout_editor_property.gd")

func can_handle(object: Object) -> bool:
	return object is DockableContainer

func parse_begin(object: Object) -> void:
	var editor_property = LayoutEditorProperty.new()
	add_property_editor("split_tree_root_node", editor_property)
