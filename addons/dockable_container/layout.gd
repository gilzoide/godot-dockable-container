"""
Layout Resources definition.

LayoutSplit are binary trees with nested LayoutSplit subtrees and LayoutPanel
leaves. Both of them inherit from LayoutNode to help with type annotation and
define common funcionality.
"""

class LayoutNode:
	extends Resource
	"""Base class for Layout tree nodes"""
	
	var parent = null

	func get_root():
		var last = self
		while last.parent:
			last = last.parent
		return last


	func _ensure_indices_in_range(data: Dictionary) -> void:
		assert("FIXME: implement on child")


class LayoutPanel:
	extends LayoutNode
	"""Layout leaf nodes, defining tabs"""

	export(PoolIntArray) var nodes = PoolIntArray()
	export(int) var current_tab: int setget set_current_tab, get_current_tab

	var _current_tab: int = 0


	func _init(new_nodes = []) -> void:
		nodes = PoolIntArray(new_nodes)
		resource_name = "Tabs"


	func push_node(node_index: int) -> void:
		nodes.append(node_index)


	func insert_node(position: int, node_index: int) -> void:
		nodes.insert(position, node_index)


	func find_node(node_index: int) -> int:
		for i in nodes.size():
			if nodes[i] == node_index:
				return i
		return -1


	func remove_node(node_index: int) -> void:
		var i = find_node(node_index)
		if i >= 0:
			nodes.remove(i)
		else:
			assert(false, "Remove failed, node %d was not found" % node_index)


	func empty() -> bool:
		return nodes.empty()


	func set_current_tab(value: int) -> void:
		_current_tab = clamp(value, 0, nodes.size() - 1)


	func get_current_tab() -> int:
		return int(clamp(_current_tab, 0, nodes.size() - 1))


	func _ensure_indices_in_range(data: Dictionary):
		var indices = data.indices
		var i = 0
		while i < nodes.size():
			var current = nodes[i]
			if not current in indices or data.has(current):
				nodes.remove(i)
			else:
				data[current] = self
				i += 1
		if not data.has("first"):
			data.first = self


class LayoutSplit:
	extends LayoutNode
	"""Layout binary tree nodes, defining subtrees and leaf panels"""

	enum Margin {
		MARGIN_LEFT,
		MARGIN_TOP,
		MARGIN_RIGHT,
		MARGIN_BOTTOM,
	}

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


	func set_first(value) -> void:
		if value == null:
			_first = LayoutPanel.new()
		else:
			_first = value
		_first.parent = self


	func get_first():
		return _first


	func set_second(value) -> void:
		if value == null:
			_second = LayoutPanel.new()
		else:
			_second = value
		_second.parent = self


	func get_second():
		return _second


	func set_split(value: int) -> void:
		if value != _split:
			_split = value
			get_root().emit_changed()


	func get_split() -> int:
		return _split


	func set_percent(value: float) -> void:
		var clamped_value = clamp(value, 0, 1)
		if not is_equal_approx(_percent, clamped_value):
			_percent = clamped_value
			get_root().emit_changed()


	func get_percent() -> float:
		return _percent


	func _ensure_indices_in_range(data: Dictionary) -> void:
		_first._ensure_indices_in_range(data)
		_second._ensure_indices_in_range(data)


	func is_horizontal() -> bool:
		return is_horizontal_margin(_split)


	static func is_horizontal_margin(margin: int) -> bool:
		return margin == MARGIN_LEFT or margin == MARGIN_RIGHT

