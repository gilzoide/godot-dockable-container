tool
extends TabContainer

const DockableContainerReferenceControl = preload("res://addons/dockable_container/dockable_reference_control.gd")


func _ready() -> void:
	drag_to_rearrange_enabled = true


func track_nodes(nodes: Array) -> void:
	var min_size = min(nodes.size(), get_child_count())
	for i in range(min_size, get_child_count()):
		remove_child(get_child(min_size))
	for i in range(min_size, nodes.size()):
		var ref_control = DockableContainerReferenceControl.new()
		add_child(ref_control)
	for i in min_size:
		var ref_control: DockableContainerReferenceControl = get_child(i)
		assert(ref_control is DockableContainerReferenceControl, "DockableContainerPanel children should always be DockableContainerReferenceControl")
		ref_control.reference_to = nodes[i]
		set_tab_title(i, nodes[i].name)
