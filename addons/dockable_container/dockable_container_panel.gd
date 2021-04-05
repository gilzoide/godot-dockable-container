tool
extends Container
class_name DockableContainerPanel

var _tabs = Tabs.new()
var _panel = PanelContainer.new()


func _ready() -> void:
	add_child(_panel)
	add_child(_tabs)
	_tabs.drag_to_rearrange_enabled = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var tabs_size = _tabs.get_combined_minimum_size()
		var tabs_rect = Rect2(0, 0, rect_size.x, tabs_size.y)
		fit_child_in_rect(_tabs, tabs_rect)
		
		var panel_rect = Rect2(0, tabs_size.y - 2, rect_size.x, rect_size.y - (tabs_size.y - 2))
		fit_child_in_rect(_panel, panel_rect)


func set_tab_names(tab_names: PoolStringArray) -> void:
	var min_size = min(tab_names.size(), _tabs.get_tab_count())
	for i in min_size:
		_tabs.set_tab_title(i, tab_names[i])
	for i in range(min_size, tab_names.size()):
		_tabs.add_tab(tab_names[i])
	for i in range(min_size, _tabs.get_tab_count()):
		_tabs.remove_tab(i)


func clear_tabs() -> void:
	for i in _tabs.get_tab_count():
		_tabs.remove_tab(0)


func push_tab(named: String) -> void:
	_tabs.add_tab(named)


func get_panel_rect() -> Rect2:
	var rect = _panel.get_rect()
	var style = _panel.get_stylebox("panel")
	if style:
		rect = rect.grow_individual(-style.content_margin_left, -style.content_margin_top, -style.content_margin_right, -style.content_margin_bottom)
	return rect
