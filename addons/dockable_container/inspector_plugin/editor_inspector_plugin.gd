extends EditorInspectorPlugin

const DockableContainer = preload("res://addons/dockable_container/dockable_container.gd")
const LayoutEditorProperty = preload("res://addons/dockable_container/inspector_plugin/layout_editor_property.gd")

func can_handle(object: Object) -> bool:
	return object is DockableContainer


func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int) -> bool:
	if path == "layout":
		var editor_property = LayoutEditorProperty.new()
		add_property_editor("layout", editor_property)
	return false
