tool
extends TabContainer

signal control_moved(control)


const DockableContainerReferenceControl = preload("res://addons/dockable_container/dockable_reference_control.gd")

var leaf


func _ready() -> void:
	drag_to_rearrange_enabled = true


func track_nodes(nodes: Array, leaf) -> void:
	self.leaf = leaf
	var min_size = min(nodes.size(), get_child_count())
	for i in range(min_size, get_child_count()):
		var child = get_child(min_size)
		remove_child(child)
		child.queue_free()
	for i in range(min_size, nodes.size()):
		var ref_control = DockableContainerReferenceControl.new()
		add_child(ref_control)
		ref_control.connect("tree_entered", self, "_on_control_moved", [ref_control])
		ref_control.connect("moved_in_parent", self, "_on_control_moved")
	assert(nodes.size() == get_child_count(), "FIXME")
	for i in nodes.size():
		var ref_control: DockableContainerReferenceControl = get_child(i)
		assert(ref_control is DockableContainerReferenceControl, "DockableContainerPanel children should always be DockableContainerReferenceControl")
		ref_control.reference_to = nodes[i]
		set_tab_title(i, nodes[i].name)


func get_child_rect() -> Rect2:
	var control = get_current_tab_control()
	return Rect2(rect_position + control.rect_position, control.rect_size)


func _on_control_moved(control):
	emit_signal("control_moved", control)
