extends "res://addons/dockable_container/dockable_container_tree.gd"

export(PoolIntArray) var nodes = PoolIntArray()
export(int) var current_tab: int setget set_current_tab, get_current_tab

var _current_tab: int = 0


func _init(nodes_ = []) -> void:
	nodes = PoolIntArray(nodes_)
	resource_name = "Leaf"


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
	return _current_tab


func _ensure_indices_in_range(data: Dictionary):
	var indices = data.indices
	var i = 0
	var removed_once = false
	while i < nodes.size():
		var current = nodes[i]
		if not current in indices or data.has(current):
			nodes.remove(i)
			removed_once = true
		else:
			data[current] = self
			i += 1
	if not data.has("first"):
		data.first = self
