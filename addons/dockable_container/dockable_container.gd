tool
extends Container

signal layout_changed()
signal child_tab_selected()

const SplitHandle = preload("res://addons/dockable_container/split_handle.gd")
const DockablePanel = preload("res://addons/dockable_container/dockable_panel.gd")
const DragNDropPanel = preload("res://addons/dockable_container/drag_n_drop_panel.gd")
const Layout = preload("res://addons/dockable_container/layout.gd")
const LayoutRoot = preload("res://addons/dockable_container/layout_root.gd")

export(int, "Left", "Center", "Right") var tab_align = TabContainer.ALIGN_CENTER setget set_tab_align, get_tab_align
export(int) var rearrange_group = 0
export(Resource) var layout = Layout.LayoutPanel.new() setget set_layout, get_layout

var _layout_root = LayoutRoot.new()
var _panel_container = Container.new()
var _split_container = Container.new()
var _drag_n_drop_panel = DragNDropPanel.new()
var _drag_panel: DockablePanel
var _current_panel_index = 0
var _current_split_index = 0
var _tab_align = TabContainer.ALIGN_CENTER
var _children_names = {}
var _layout_dirty = false


func _ready() -> void:
	set_process_input(false)
	_panel_container.name = "_panel_container"
	.add_child(_panel_container)
	move_child(_panel_container, 0)
	_split_container.name = "_split_container"
	_split_container.mouse_filter = MOUSE_FILTER_PASS
	_panel_container.add_child(_split_container)
	
	_drag_n_drop_panel.name = "_drag_n_drop_panel"
	_drag_n_drop_panel.mouse_filter = MOUSE_FILTER_PASS
	_drag_n_drop_panel.set_drag_forwarding(self)
	_drag_n_drop_panel.visible = false
	.add_child(_drag_n_drop_panel)
	
	if not _layout_root.root:
		_layout_root.set_root(null, false)
	_update_layout_with_children()
	_layout_root.connect("changed", self, "queue_sort")


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_resort()
	elif what == NOTIFICATION_DRAG_BEGIN:
		_drag_n_drop_panel.visible = true
		set_process_input(true)
	elif what == NOTIFICATION_DRAG_END:
		_drag_n_drop_panel.visible = false
		set_process_input(false)


func _input(event: InputEvent) -> void:
	assert(get_viewport().gui_is_dragging(), "FIXME: should only be called when dragging")
	if event is InputEventMouseMotion:
		var local_position = get_local_mouse_position()
		var panel
		for i in range(1, _panel_container.get_child_count()):
			var p = _panel_container.get_child(i)
			if p.get_rect().has_point(local_position):
				panel = p
				break
		_drag_panel = panel
		if not panel:
			return
		fit_child_in_rect(_drag_n_drop_panel, panel.get_child_rect())


func add_child(node: Node, legible_unique_name: bool = false) -> void:
	.add_child(node, legible_unique_name)
	_drag_n_drop_panel.raise()
	_track_and_add_node(node)


func add_child_below_node(node: Node, child_node: Node, legible_unique_name: bool = false) -> void:
	.add_child_below_node(node, child_node, legible_unique_name)
	_drag_n_drop_panel.raise()
	_track_and_add_node(child_node)


func remove_child(node: Node) -> void:
	.remove_child(node)
	_untrack_node(node)


func can_drop_data_fw(position: Vector2, data, from_control) -> bool:
	return from_control == _drag_n_drop_panel and data is Dictionary and data.get("type") == "tabc_element"


func drop_data_fw(position: Vector2, data, from_control) -> void:
	assert(from_control == _drag_n_drop_panel, "FIXME")
	
	var from_node: DockablePanel = get_node(data.from_path)
	if _drag_panel == null or (from_node == _drag_panel and _drag_panel.get_child_count() == 1):
		return
	
	var moved_tab = from_node.get_tab_control(data.tabc_element)
	var moved_reference = moved_tab.reference_to
	
	var margin = _drag_n_drop_panel.get_hover_margin()
	_layout_root.split_leaf_with_node(_drag_panel.leaf, moved_reference, margin)
	
	emit_signal("layout_changed")
	queue_sort()


func set_control_as_current_tab(control: Control) -> void:
	assert(control.get_parent_control() == self, "Trying to focus a control not managed by this container")
	var leaf = _layout_root.get_leaf_for_node(control)
	if not leaf:
		return
	var position_in_leaf = leaf.find_node(control)
	if position_in_leaf < 0:
		return
	var panel
	for i in range(1, _panel_container.get_child_count()):
		var p = _panel_container.get_child(i)
		if p.leaf == leaf:
			panel = p
			break
	if not panel:
		return
	panel.current_tab = position_in_leaf


func set_layout(value: Layout.LayoutNode) -> void:
	if value == null:
		value = Layout.LayoutPanel.new()
	_layout_root.set_root(value, false)
	_layout_dirty = true
	queue_sort()


func get_layout() -> Layout.LayoutNode:
	return _layout_root.root


func set_tab_align(tab_align: int) -> void:
	_tab_align = tab_align
	for i in range(1, _panel_container.get_child_count()):
		var panel = _panel_container.get_child(i)
		panel.tab_align = tab_align


func get_tab_align() -> int:
	return _tab_align


func _update_layout_with_children() -> void:
	var names = PoolStringArray()
	_children_names.clear()
	for i in range(1, get_child_count() - 1):
		var c = get_child(i)
		if _track_node(c):
			names.append(c.name)
	_layout_root.update_nodes(names)
	_layout_dirty = false
	queue_sort()


func _track_node(node: Node) -> bool:
	if node == _panel_container or node == _drag_n_drop_panel or not node is Control or node.is_set_as_toplevel():
		return false
	_children_names[node] = node.name
	_children_names[node.name] = node
	if not node.is_connected("renamed", self, "_on_child_renamed"):
		node.connect("renamed", self, "_on_child_renamed", [node])
	if not node.is_connected("tree_exiting", self, "_untrack_node"):
		node.connect("tree_exiting", self, "_untrack_node", [node])
	return true


func _track_and_add_node(node: Node) -> void:
	var tracked_name = _children_names.get(node)
	if not _track_node(node):
		return
	if tracked_name and tracked_name != node.name:
		_layout_root.rename_node(tracked_name, node.name)
	_layout_dirty = true


func _untrack_node(node: Node) -> void:
	_children_names.erase(node)
	_children_names.erase(node.name)
	if node.is_connected("renamed", self, "_on_child_renamed"):
		node.disconnect("renamed", self, "_on_child_renamed")
	if node.is_connected("tree_exiting", self, "_untrack_node"):
		node.disconnect("tree_exiting", self, "_untrack_node")
	_layout_dirty = true


func _resort() -> void:
	assert(_panel_container, "FIXME: resorting without _panel_container")
	if _panel_container.get_position_in_parent() != 0:
		move_child(_panel_container, 0)
	if _drag_n_drop_panel.get_position_in_parent() < get_child_count() - 1:
		_drag_n_drop_panel.raise()
	
	if _layout_dirty:
		_update_layout_with_children()
	
	var rect = Rect2(Vector2.ZERO, rect_size)
	fit_child_in_rect(_panel_container, rect)
	_panel_container.fit_child_in_rect(_split_container, rect)
	
	_current_panel_index = 1
	_current_split_index = 0
	_set_tree_or_leaf_rect(_layout_root.root, rect)
	_untrack_children_after(_panel_container, _current_panel_index)
	_untrack_children_after(_split_container, _current_split_index)


func _set_tree_or_leaf_rect(tree_or_leaf: Layout.LayoutNode, rect: Rect2) -> void:
	if tree_or_leaf is Layout.LayoutSplit:
		var split = _get_split(_current_split_index)
		split.split_tree = tree_or_leaf
		_current_split_index += 1
		var split_rects = split.get_split_rects(rect)
		_split_container.fit_child_in_rect(split, split_rects.self)
		_set_tree_or_leaf_rect(tree_or_leaf.first, split_rects.first)
		_set_tree_or_leaf_rect(tree_or_leaf.second, split_rects.second)
	elif tree_or_leaf is Layout.LayoutPanel:
		var panel = _get_panel(_current_panel_index)
		_current_panel_index += 1
		var nodes = []
		for n in tree_or_leaf.names:
			var node = _children_names.get(n)
			if node:
				assert(node is Control, "FIXME: node is not a control %s" % node)
				assert(node.get_parent_control() == self, "FIXME: node is not child of container %s" % node)
				nodes.append(node)
		panel.track_nodes(nodes, tree_or_leaf)
		_panel_container.fit_child_in_rect(panel, rect)
	else:
		assert(false, "Invalid Resource, should be branch or leaf, found %s" % tree_or_leaf)


func _get_panel(idx: int) -> DockablePanel:
	assert(_panel_container, "FIXME: creating panel without _panel_container")
	if idx < _panel_container.get_child_count():
		return _panel_container.get_child(idx)
	var panel = DockablePanel.new()
	panel.tab_align = _tab_align
	panel.set_tabs_rearrange_group(max(0, rearrange_group))
	_panel_container.add_child(panel)
	panel.connect("control_moved", self, "_on_reference_control_moved")
	panel.connect("tab_changed", self, "_on_panel_tab_changed", [panel])
	return panel


func _get_split(idx: int) -> SplitHandle:
	assert(_split_container, "FIXME: creating split without _split_container")
	if idx < _split_container.get_child_count():
		return _split_container.get_child(idx)
	var split = SplitHandle.new()
	_split_container.add_child(split)
	return split


static func _untrack_children_after(node, idx: int) -> void:
	for i in range(idx, node.get_child_count()):
		var child = node.get_child(idx)
		node.remove_child(child)
		child.queue_free()


func _on_reference_control_moved(control: Control) -> void:
	var panel = control.get_parent_control()
	assert(panel is DockablePanel, "FIXME: reference control was moved to something other than DockableContainerPanel")
	
	if panel.get_child_count() <= 1:
		return
	
	var relative_position_in_leaf = control.get_position_in_parent()
	_layout_root.move_node_to_leaf(control.reference_to, panel.leaf, relative_position_in_leaf)
	
	emit_signal("layout_changed")
	queue_sort()


func _on_panel_tab_changed(tab: int, panel: DockablePanel) -> void:
	if not panel.leaf or panel.leaf.empty():
		return
	emit_signal("child_tab_selected")


func _on_child_renamed(child: Node) -> void:
	var old_name = _children_names.get(child)
	if not old_name:
		return
	_children_names.erase(old_name)
	_children_names[child] = child.name
	_children_names[child.name] = child
	_layout_root.rename_node(old_name, child.name)
