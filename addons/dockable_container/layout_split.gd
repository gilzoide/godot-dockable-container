tool
extends "res://addons/dockable_container/layout_node.gd"
"""Layout binary tree nodes, defining subtrees and leaf panels"""

enum Margin {
	MARGIN_LEFT,
	MARGIN_TOP,
	MARGIN_RIGHT,
	MARGIN_BOTTOM,
}

const LayoutPanel = preload("res://addons/dockable_container/layout_panel.gd")

export(Margin) var split = MARGIN_RIGHT setget set_split, get_split
export(float, 0, 1) var percent = 0.5 setget set_percent, get_percent
export(Resource) var first = LayoutPanel.new() setget set_first, get_first
export(Resource) var second = LayoutPanel.new() setget set_second, get_second

var _split = MARGIN_RIGHT
var _percent = 0.5
var _first
var _second


func _init() -> void:
	resource_name = "Split"


func clone():
	var new_split = get_script().new()
	new_split._split = _split
	new_split._percent = _percent
	new_split.first = _first.clone()
	new_split.second = _second.clone()
	return new_split


func set_first(value) -> void:
	if value == null:
		_first = LayoutPanel.new()
	else:
		_first = value
	_first.parent = self
	emit_signal("changed")


func get_first():
	return _first


func set_second(value) -> void:
	if value == null:
		_second = LayoutPanel.new()
	else:
		_second = value
	_second.parent = self
	emit_signal("changed")


func get_second():
	return _second


func set_split(value: int) -> void:
	if value != _split:
		_split = value
		var root = get_root()
		if root:
			root.split_parameters_changed()
		emit_signal("changed")


func get_split() -> int:
	return _split


func set_percent(value: float) -> void:
	var clamped_value = clamp(value, 0, 1)
	if not is_equal_approx(_percent, clamped_value):
		_percent = clamped_value
		var root = get_root()
		if root:
			root.split_parameters_changed()
		emit_signal("changed")


func get_percent() -> float:
	return _percent


func get_names() -> PoolStringArray:
	var names = _first.get_names()
	names.append_array(_second.get_names())
	return names


func empty() -> bool:
	return _first.empty() and _second.empty()


func is_horizontal() -> bool:
	return is_horizontal_margin(_split)


func get_minimum_size() -> Vector2:
	var first_minimum_size = _first.get_minimum_size()
	var second_minimum_size = _second.get_minimum_size()
	if is_horizontal():
		return Vector2(first_minimum_size.x + second_minimum_size.x, max(first_minimum_size.y, second_minimum_size.y))
	else:
		return Vector2(max(first_minimum_size.x, second_minimum_size.x), first_minimum_size.y + second_minimum_size.y)


static func is_horizontal_margin(margin: int) -> bool:
	return margin == MARGIN_LEFT or margin == MARGIN_RIGHT
