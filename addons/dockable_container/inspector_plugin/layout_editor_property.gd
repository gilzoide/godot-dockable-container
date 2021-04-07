extends EditorProperty

const DockableContainer = preload("res://addons/dockable_container/dockable_container.gd")

var _container = DockableContainer.new()


func _ready() -> void:
	rect_min_size = Vector2(128, 128)
	add_child(_container)
	set_bottom_editor(_container)
	_container.connect("layout_changed", self, "_on_layout_changed")
	
	var original_container: DockableContainer = get_edited_object()
	for i in range(1, original_container.get_child_count() - 1):
		var child = original_container.get_child(i)
		var new_control = Label.new()
		new_control.name = child.name
		new_control.text = child.name
		_container.add_child(new_control)
	_container._layout_root_node = original_container._layout_root_node
	_container._layout_root = original_container._layout_root


func _on_layout_changed() -> void:
	emit_changed(get_edited_property(), _container.get(get_edited_property()))
