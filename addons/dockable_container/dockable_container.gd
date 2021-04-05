tool
extends Container
class_name DockableContainer

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
	
	var rect = Rect2(Vector2.ZERO, rect_size)
	fit_child_in_rect(_panel_container, rect)
	
	var panel_i = 0
	var current_panel = _get_panel(panel_i)
	current_panel.clear_tabs()
	for i in range(1, get_child_count()):
		var child = get_child(i)
		if child is DockableContainerSplit:
			_panel_container.fit_child_in_rect(current_panel, child.first_rect(rect))
			panel_i += 1
			current_panel = _get_panel(panel_i)
			rect = child.second_rect(rect)
			_panel_container.fit_child_in_rect(current_panel, rect)
			current_panel.clear_tabs()
		elif not child is Control or child.is_set_as_toplevel():
			continue
		else:
			current_panel.push_tab(child.name)
			fit_child_in_rect(child, current_panel.get_panel_rect())
	_panel_container.fit_child_in_rect(current_panel, rect)


func _get_panel(idx: int):
	assert(_panel_container, "FIXME: creating panel without _panel_container")
	if idx < _panel_container.get_child_count():
		return _panel_container.get_child(idx)
	var panel = DockableContainerPanel.new()
	_panel_container.add_child(panel)
	return panel
