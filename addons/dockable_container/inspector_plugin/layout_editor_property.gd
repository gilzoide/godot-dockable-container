extends EditorProperty

const DockableContainer = preload("res://addons/dockable_container/dockable_container.gd")
const Layout = preload("res://addons/dockable_container/layout.gd")
const LayoutRoot = preload("res://addons/dockable_container/layout_root.gd")

var _container = DockableContainer.new()


func _ready() -> void:
	rect_min_size = Vector2(128, 256)
	add_child(_container)
	set_bottom_editor(_container)
	_container.rect_min_size = rect_min_size
	_container.connect("layout_changed", self, "_on_layout_changed")
	_container.connect("child_tab_selected", self, "_on_child_tab_selected")
	
	var original_container: DockableContainer = get_edited_object()
	for i in range(1, original_container.get_child_count() - 1):
		var child = original_container.get_child(i)
		var new_control = Label.new()
		new_control.name = child.name
		new_control.align = Label.ALIGN_CENTER
		new_control.valign = Label.VALIGN_CENTER
		new_control.text = child.name
		_container.add_child(new_control)


func update_property() -> void:
	var original_container: DockableContainer = get_edited_object()
	var value = original_container.get(get_edited_property())
	if value == null:
		value = LayoutRoot.new()
		value.root = Layout.LayoutPanel.new()
		original_container.set(get_edited_property(), value)
		original_container._update_tree_indices()
		value.connect("changed", original_container, "queue_sort")
		value.connect("changed", _container, "queue_sort")
	_container.set(get_edited_property(), value)
	_container._update_tree_indices()


func _on_child_tab_selected(_child_index: int) -> void:
	emit_changed(get_edited_property(), _container.get(get_edited_property()))
	var original_container: DockableContainer = get_edited_object()
	original_container.queue_sort()


func _on_layout_changed() -> void:
	emit_changed(get_edited_property(), _container.get(get_edited_property()))
	var original_container: DockableContainer = get_edited_object()
	original_container.queue_sort()
