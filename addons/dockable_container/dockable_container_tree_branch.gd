tool
extends "res://addons/dockable_container/dockable_container_tree.gd"

enum Margin {
	MARGIN_LEFT,
	MARGIN_TOP,
	MARGIN_RIGHT,
	MARGIN_BOTTOM,
}

const Leaf = preload("res://addons/dockable_container/dockable_container_tree_leaf.gd")

export(Margin) var split = MARGIN_RIGHT setget set_split, get_split
export(float, 0, 1) var percent = 0.5 setget set_percent, get_percent
export(Resource) var first setget set_first, get_first
export(Resource) var second setget set_second, get_second

var parent = null

var _split = MARGIN_RIGHT
var _percent = 0.5
var _first = Leaf.new()
var _second = Leaf.new()


func _init() -> void:
	resource_name = "Branch"


func set_first(value) -> void:
	if _first:
		if _first.is_connected("changed", self, "_on_child_changed"):
			_first.disconnect("changed", self, "_on_child_changed")
		_first.parent = null
	if value == null:
		_first = Leaf.new()
	else:
		_first = value
	_first.parent = self
	_first.connect("changed", self, "_on_child_changed")
	emit_changed()


func get_first():
	return _first


func set_second(value) -> void:
	if _second:
		if _second.is_connected("changed", self, "_on_child_changed"):
			_second.disconnect("changed", self, "_on_child_changed")
		_second.parent = null
	if value == null:
		_second = Leaf.new()
	else:
		_second = value
	_second.parent = self
	_second.connect("changed", self, "_on_child_changed")
	emit_changed()


func get_second():
	return _second


func set_split(value: int) -> void:
	if value != _split:
		_split = value
		emit_changed()


func get_split() -> int:
	return _split


func set_percent(value: float) -> void:
	var clamped_value = clamp(value, 0, 1)
	if not is_equal_approx(_percent, clamped_value):
		_percent = clamped_value
		emit_changed()


func get_percent() -> float:
	return _percent


func _ensure_indices_in_range(data: Dictionary) -> void:
	_first._ensure_indices_in_range(data)
	_second._ensure_indices_in_range(data)


func is_horizontal() -> bool:
	return is_horizontal_margin(_split)


func is_split_before() -> bool:
	return is_split_before_margin(_split)


static func is_horizontal_margin(margin: int) -> bool:
	return margin == MARGIN_LEFT or margin == MARGIN_RIGHT


static func is_split_before_margin(margin: int) -> bool:
	return margin == MARGIN_LEFT or margin == MARGIN_TOP


func _on_child_changed() -> void:
	emit_changed()
