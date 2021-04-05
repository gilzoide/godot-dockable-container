tool
extends Container
class_name DockableContainer

const DockableContainerPanel = preload("res://addons/dockable_container/dockable_container_panel.gd")

var _panel_container = Container.new()


func _ready() -> void:
	add_child(_panel_container)
	move_child(_panel_container, 0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_resort()


func _resort() -> void:
	assert(_panel_container, "FIXME: resorting without _panel_container")
	assert(_panel_container.get_position_in_parent() == 0, "FIXME: _panel_container is not first child")
	
	var panel_i = 0
	var current_panel = _get_panel(panel_i)
	var current_panel_and_children = {
		"panel": current_panel,
		"split": DockableContainerSplit.Split.HORIZONTAL,
		"percent": 1,
		"children": [],
	}
	var all_panel_and_children = [current_panel_and_children]
	for i in range(1, get_child_count()):
		var child = get_child(i)
		if child is DockableContainerSplit:
			if not current_panel_and_children.children.empty():
				current_panel_and_children.split = child.split
				current_panel_and_children.percent = child.percent
				panel_i += 1
				current_panel = _get_panel(panel_i)
				current_panel_and_children = {
					"panel": current_panel,
					"split": DockableContainerSplit.Split.HORIZONTAL,
					"percent": 1,
					"children": [],
				}
				all_panel_and_children.append(current_panel_and_children)
		elif not child is Control or child.is_set_as_toplevel():
			continue
		else:
			current_panel_and_children.children.append(child)
	if current_panel_and_children.children.empty():
		all_panel_and_children.pop_back()
	
	var rect = Rect2(Vector2.ZERO, rect_size)
	fit_child_in_rect(_panel_container, rect)
	for data in all_panel_and_children:
		var panel = data.panel
		var panel_rect = DockableContainerSplit.first_rect(rect, data.split, data.percent)
		_panel_container.fit_child_in_rect(panel, panel_rect)
		panel.track_nodes(data.children)
		rect = DockableContainerSplit.second_rect(rect, data.split, data.percent)


func _get_panel(idx: int):
	assert(_panel_container, "FIXME: creating panel without _panel_container")
	if idx < _panel_container.get_child_count():
		return _panel_container.get_child(idx)
	var panel = DockableContainerPanel.new()
	_panel_container.add_child(panel)
	return panel
