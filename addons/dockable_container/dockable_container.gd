tool
extends Container

const DockableContainerSplit = preload("res://addons/dockable_container/dockable_container_split.gd")
const DockableContainerPanel = preload("res://addons/dockable_container/dockable_container_panel.gd")
const DockableContainerReferenceControl = preload("res://addons/dockable_container/dockable_reference_control.gd")
const DockableContainerDragDrawer = preload("res://addons/dockable_container/dockable_container_drag_drawer.gd")
const DockableContainerTreeNode = preload("res://addons/dockable_container/dockable_container_tree.gd")
const DockableContainerTreeRoot = preload("res://addons/dockable_container/dockable_container_tree_root.gd")
const DockableContainerTreeBranch = preload("res://addons/dockable_container/dockable_container_tree_branch.gd")
const DockableContainerTreeLeaf = DockableContainerTreeBranch.Leaf

export(int) var rearrange_group = 0
export(Resource) var split_tree_root_node setget set_split_tree_root_node, get_split_tree_root_node

var _split_tree_root_node
var _split_tree = DockableContainerTreeRoot.new()
var _panel_container = Container.new()
var _split_container = Container.new()
var _drag_checker = DockableContainerDragDrawer.new()
var _drag_panel: DockableContainerPanel
var _current_panel_index = 0
var _current_split_index = 0


func _ready() -> void:
	set_process_input(false)
	add_child(_panel_container)
	move_child(_panel_container, 0)
	_panel_container.add_child(_split_container)
	_split_container.mouse_filter = MOUSE_FILTER_PASS
	
	_drag_checker.mouse_filter = MOUSE_FILTER_PASS
	_drag_checker.set_drag_forwarding(self)
	_drag_checker.visible = false
	add_child(_drag_checker)
	
	if Engine.editor_hint:
		yield(get_tree(), "idle_frame")
	_split_tree.root = _split_tree_root_node
	_split_tree.connect("changed", self, "queue_sort")
	_split_tree.ensure_indices_in_range(1, get_child_count() - 2)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_resort()
	elif what == NOTIFICATION_DRAG_BEGIN:
		_drag_checker.visible = true
		set_process_input(true)
	elif what == NOTIFICATION_DRAG_END:
		_drag_checker.visible = false
		set_process_input(false)


func _input(event: InputEvent) -> void:
	assert(get_viewport().gui_is_dragging(), "FIXME: should only be called when dragging")
	if event is InputEventMouseMotion:
		var panel
		for i in range(1, _panel_container.get_child_count()):
			var p = _panel_container.get_child(i)
			if p.get_rect().has_point(event.position):
				panel = p
				break
		_drag_panel = panel
		if not panel:
			return
		fit_child_in_rect(_drag_checker, panel.get_child_rect())


func _resort() -> void:
	assert(_panel_container, "FIXME: resorting without _panel_container")
	assert(_panel_container.get_position_in_parent() == 0, "FIXME: _panel_container is not first child")
	if _drag_checker.get_position_in_parent() < get_child_count() - 1:
		_drag_checker.raise()
	
	var rect = Rect2(Vector2.ZERO, rect_size)
	fit_child_in_rect(_panel_container, rect)
	_panel_container.fit_child_in_rect(_split_container, rect)
	
	_current_panel_index = 1
	_current_split_index = 0
	_set_tree_or_leaf_rect(_split_tree.root, rect)
	_untrack_children_after(_panel_container, _current_panel_index + 1)
	_untrack_children_after(_split_container, _current_split_index + 1)


func _set_tree_or_leaf_rect(tree_or_leaf: DockableContainerTreeNode, rect: Rect2) -> void:
	if tree_or_leaf is DockableContainerTreeBranch:
		var split = _get_split(_current_split_index)
		split.split_tree = tree_or_leaf
		_current_split_index += 1
		var split_rects = split.get_split_rects(rect)
		_split_container.fit_child_in_rect(split, split_rects.self)
		_set_tree_or_leaf_rect(tree_or_leaf.first, split_rects.first)
		_set_tree_or_leaf_rect(tree_or_leaf.second, split_rects.second)
	elif tree_or_leaf is DockableContainerTreeLeaf:
		var panel = _get_panel(_current_panel_index)
		_current_panel_index += 1
		var nodes = []
		for n in tree_or_leaf.nodes:
			nodes.append(get_child(n))
		panel.track_nodes(nodes, tree_or_leaf)
		_panel_container.fit_child_in_rect(panel, rect)
	else:
		assert(false, "Invalid Resource, should be branch or leaf, found %s" % tree_or_leaf)


func set_split_tree_root_node(value: DockableContainerTreeNode) -> void:
	if value == null:
		var nodes = range(1, get_child_count() - 1)
		_split_tree_root_node = DockableContainerTreeLeaf.new(nodes)
	else:
		_split_tree_root_node = value
	_split_tree.root = _split_tree_root_node


func get_split_tree_root_node() -> DockableContainerTreeNode:
	return _split_tree_root_node


func can_drop_data_fw(position: Vector2, data, from_control) -> bool:
	return from_control == _drag_checker and data is Dictionary and data.get("type") == "tabc_element"


func drop_data_fw(position: Vector2, data, from_control) -> void:
	assert(from_control == _drag_checker, "FIXME")
	
	var from_node: DockableContainerPanel = get_node(data.from_path)
	if from_node == _drag_panel and _drag_panel.get_child_count() == 1:
		return
	
	var moved_tab = from_node.get_tab_control(data.tabc_element)
	var moved_reference = moved_tab.reference_to
	var moved_parent_index = moved_reference.get_position_in_parent()
	
	var margin = _drag_checker.get_hover_margin()
	_split_tree.split_leaf_with_node(_drag_panel.leaf, moved_parent_index, margin)
	
	queue_sort()


func _get_panel(idx: int) -> DockableContainerPanel:
	assert(_panel_container, "FIXME: creating panel without _panel_container")
	if idx < _panel_container.get_child_count():
		return _panel_container.get_child(idx)
	var panel = DockableContainerPanel.new()
	panel.set_tabs_rearrange_group(max(0, rearrange_group))
	_panel_container.add_child(panel)
	panel.connect("control_moved", self, "_on_reference_control_moved")
	return panel


func _get_split(idx: int) -> DockableContainerSplit:
	assert(_split_container, "FIXME: creating split without _split_container")
	if idx < _split_container.get_child_count():
		return _split_container.get_child(idx)
	var split = DockableContainerSplit.new()
	_split_container.add_child(split)
	return split


static func _untrack_children_after(node, idx: int) -> void:
	for i in range(idx, node.get_child_count()):
		var child = node.get_child(idx)
		node.remove_child(child)
		child.queue_free()


func _on_reference_control_moved(control: Control) -> void:
	var panel = control.get_parent_control()
	assert(panel is DockableContainerPanel, "FIXME: reference control was moved to something other than DockableContainerPanel")
	if panel.get_child_count() <= 1:
		return
	var position_in_parent = control.get_position_in_parent()
	if position_in_parent == 0:
		var next = panel.get_child(position_in_parent + 1)
		assert(next is DockableContainerReferenceControl, "FIXME")
		move_child(control.reference_to, next.reference_to.get_position_in_parent())
	else:
		var previous = panel.get_child(position_in_parent - 1)
		assert(previous is DockableContainerReferenceControl, "FIXME")
		move_child(control.reference_to, previous.reference_to.get_position_in_parent() + 1)
