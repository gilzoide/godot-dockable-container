tool
extends Container

const DockableContainerSplit = preload("res://addons/dockable_container/dockable_container_split.gd")
const DockableContainerPanel = preload("res://addons/dockable_container/dockable_container_panel.gd")
const DockableContainerReferenceControl = preload("res://addons/dockable_container/dockable_reference_control.gd")
const DockableContainerDragDrawer = preload("res://addons/dockable_container/dockable_container_drag_drawer.gd")

export(int) var rearrange_group = 0
var _panel_container = Container.new()
var _drag_checker = DockableContainerDragDrawer.new()
var _drag_panel


func _ready() -> void:
	set_process_input(false)
	add_child(_panel_container)
	move_child(_panel_container, 0)
	_drag_checker.mouse_filter = MOUSE_FILTER_PASS
	_drag_checker.set_drag_forwarding(self)
	_drag_checker.visible = false
	add_child(_drag_checker)
	for c in get_children():
		if c is DockableContainerSplit:
			c.connect("changed", self, "queue_sort")


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
		for p in _panel_container.get_children():
			if p.get_rect().has_point(event.position):
				panel = p
				break
		if not panel:
			return
		fit_child_in_rect(_drag_checker, panel.get_child_rect())


func _resort() -> void:
	assert(_panel_container, "FIXME: resorting without _panel_container")
	assert(_panel_container.get_position_in_parent() == 0, "FIXME: _panel_container is not first child")
	if _drag_checker.get_position_in_parent() < get_child_count() - 1:
		_drag_checker.raise()
	
	var panel_i = 0
	var current_panel = _get_panel(panel_i)
	var current_panel_and_children = {
		"panel": current_panel,
		#"split": null,  # split will be set if encountered in children
		"children": [],
	}
	var all_panel_and_children = [current_panel_and_children]
	for i in range(1, get_child_count() - 1):
		var child = get_child(i)
		if child is DockableContainerSplit:
			if current_panel_and_children.children.empty() and not Engine.editor_hint:
				call_deferred("remove_child", child)
				child.call_deferred("queue_free")
			else:
				current_panel_and_children.split = child
				panel_i += 1
				current_panel = _get_panel(panel_i)
				current_panel_and_children = {
					"panel": current_panel,
					#"split": null,  # split will be set if encountered in children
					"children": [],
				}
				all_panel_and_children.append(current_panel_and_children)
		elif not child is Control or child.is_set_as_toplevel():
			continue
		else:
			current_panel_and_children.children.append(child)
	if current_panel_and_children.children.empty():
		all_panel_and_children.pop_back()
	if all_panel_and_children.empty():
		return
	var last_split = all_panel_and_children[-1].get("split")
	if last_split:
		last_split.set_percent(1, false)
	_untrack_panels_after(panel_i + 1)
	
	var rect = Rect2(Vector2.ZERO, rect_size)
	fit_child_in_rect(_panel_container, rect)
	for data in all_panel_and_children:
		var panel = data.panel
		panel.track_nodes(data.children)
		var split = data.get("split")
		if split:
			var split_rects = split.get_split_rects(rect)
			_panel_container.fit_child_in_rect(panel, split_rects.first)
			fit_child_in_rect(split, split_rects.self)
			rect = split_rects.second
		else:
			_panel_container.fit_child_in_rect(panel, rect)


func can_drop_data_fw(position: Vector2, data, from_control) -> bool:
	return from_control == _drag_checker


func drop_data_fw(position: Vector2, data, from_control) -> void:
	assert(from_control == _drag_checker, "FIXME")



func _get_panel(idx: int):
	assert(_panel_container, "FIXME: creating panel without _panel_container")
	if idx < _panel_container.get_child_count():
		return _panel_container.get_child(idx)
	var panel = DockableContainerPanel.new()
	panel.set_tabs_rearrange_group(max(0, rearrange_group))
	_panel_container.add_child(panel)
	panel.connect("control_moved", self, "_on_reference_control_moved")
	return panel


func _untrack_panels_after(idx: int) -> void:
	for i in range(idx, _panel_container.get_child_count()):
		var panel = _panel_container.get_child(idx)
		_panel_container.remove_child(panel)
		panel.queue_free()


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
