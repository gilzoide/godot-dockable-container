tool
extends TabContainer

signal control_moved(control)

const ReferenceControl = preload("res://addons/dockable_container/dockable_panel_reference_control.gd")
const Layout = preload("res://addons/dockable_container/layout.gd")

var leaf: Layout.LayoutPanel setget set_leaf, get_leaf

var _leaf: Layout.LayoutPanel


func _ready() -> void:
	drag_to_rearrange_enabled = true


func track_nodes(nodes: Array, new_leaf: Layout.LayoutPanel) -> void:
	var min_size = min(nodes.size(), get_child_count())
	# remove spare children
	for i in range(min_size, get_child_count()):
		var child = get_child(min_size)
		remove_child(child)
		child.queue_free()
	# add missing children
	for i in range(min_size, nodes.size()):
		var ref_control = ReferenceControl.new()
		add_child(ref_control)
		ref_control.connect("tree_entered", self, "_on_control_moved", [ref_control])
		ref_control.connect("moved_in_parent", self, "_on_control_moved")
	assert(nodes.size() == get_child_count(), "FIXME")
	# setup children
	for i in nodes.size():
		var ref_control: ReferenceControl = get_child(i)
		ref_control.reference_to = nodes[i]
		set_tab_title(i, nodes[i].name)
	set_leaf(new_leaf)
	if get_tab_count() > 0:
		current_tab = new_leaf.current_tab


func get_child_rect() -> Rect2:
	var control = get_current_tab_control()
	return Rect2(rect_position + control.rect_position, control.rect_size)


func set_leaf(value: Layout.LayoutPanel) -> void:
	if _leaf and is_connected("tab_changed", _leaf, "set_current_tab"):
		disconnect("tab_changed", _leaf, "set_current_tab")
	_leaf = value
	connect("tab_changed", _leaf, "set_current_tab")


func get_leaf() -> Layout.LayoutPanel:
	return _leaf


func get_layout_minimum_size() -> Vector2:
	return get_combined_minimum_size()


func _on_control_moved(control):
	emit_signal("control_moved", control)
