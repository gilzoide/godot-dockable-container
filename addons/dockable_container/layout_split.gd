@tool
class_name DockableLayoutSplit
extends DockableLayoutNode
# DockableLayout binary tree nodes, defining subtrees and leaf panels

enum Direction { HORIZONTAL, VERTICAL }

@export var direction := Direction.HORIZONTAL:
	get:
		return get_direction()
	set(value):
		set_direction(value)
@export_range(0, 1) var percent := 0.5:
	get = get_percent,
	set = set_percent
@export var first := DockableLayoutPanel.new():
	get:
		return get_first()
	set(value):
		set_first(value)
@export var second := DockableLayoutPanel.new():
	get:
		return get_second()
	set(value):
		set_second(value)

var _direction := Direction.HORIZONTAL
var _percent := 0.5
var _first: DockableLayoutPanel
var _second: DockableLayoutPanel


func _init() -> void:
	resource_name = "Split"


func clone() -> DockableLayoutSplit:
	var new_split := DockableLayoutSplit.new()
	new_split._direction = _direction
	new_split._percent = _percent
	new_split.first = _first.clone()
	new_split.second = _second.clone()
	return new_split


func set_first(value: DockableLayoutPanel) -> void:
	if value == null:
		_first = DockableLayoutPanel.new()
	else:
		_first = value
	_first.parent = self
	emit_tree_changed()


func get_first() -> DockableLayoutPanel:
	return _first


func set_second(value: DockableLayoutPanel) -> void:
	if value == null:
		_second = DockableLayoutPanel.new()
	else:
		_second = value
	_second.parent = self
	emit_tree_changed()


func get_second() -> DockableLayoutPanel:
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
	var names := _first.get_names()
	names.append_array(_second.get_names())
	return names


func is_empty() -> bool:
	return _first.is_empty() and _second.is_empty()


func is_horizontal() -> bool:
	return _direction == Direction.HORIZONTAL


func is_vertical() -> bool:
	return _direction == Direction.VERTICAL
