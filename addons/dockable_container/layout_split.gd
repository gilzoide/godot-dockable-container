@tool
extends "layout_node.gd"
# Layout binary tree nodes, defining subtrees and leaf panels

enum Direction {
	HORIZONTAL,
	VERTICAL,
}

const LayoutPanel = preload("layout_panel.gd")

@export var direction: Direction = Direction.HORIZONTAL:
	get:
		# TODO: Manually copy the code from this method.
		return get_direction()
	set(value):
		# TODO: Manually copy the code from this method.
		set_direction(value)
@export_range(0,1) var percent: float = 0.5:
	get:
		# TODO: Manually copy the code from this method.
		return get_percent()
	set(value):
		# TODO: Manually copy the code from this method.
		set_percent(value)
@export var first: Resource = LayoutPanel.new():
	get:
		# TODO: Manually copy the code from this method.
		return get_first()
	set(value):
		# TODO: Manually copy the code from this method.
		set_first(value)
@export var second: Resource = LayoutPanel.new():
	get:
		# TODO: Manually copy the code from this method.
		return get_second()
	set(value):
		# TODO: Manually copy the code from this method.
		set_second(value)

var _direction = Direction.HORIZONTAL
var _percent = 0.5
var _first
var _second


func _init() -> void:
	resource_name = "Split"


func clone():
	var new_split = get_script().new()
	new_split._direction = _direction
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
	emit_tree_changed()


func get_first():
	return _first


func set_second(value) -> void:
	if value == null:
		_second = LayoutPanel.new()
	else:
		_second = value
	_second.parent = self
	emit_tree_changed()


func get_second():
	return _second


func set_direction(value: int) -> void:
	if value != _direction:
		_direction = value
		emit_tree_changed()


func get_direction() -> int:
	return _direction


func set_percent(value: float) -> void:
	var clamped_value = clamp(value, 0, 1)
	if not is_equal_approx(_percent, clamped_value):
		_percent = clamped_value
		emit_tree_changed()


func get_percent() -> float:
	return _percent


func get_names() -> PackedStringArray:
	var names = _first.get_names()
	names.append_array(_second.get_names())
	return names


func empty() -> bool:
	return _first.is_empty() and _second.is_empty()


func is_horizontal() -> bool:
	return _direction == Direction.HORIZONTAL


func is_vertical() -> bool:
	return _direction == Direction.VERTICAL
