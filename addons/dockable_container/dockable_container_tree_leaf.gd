extends "res://addons/dockable_container/dockable_container_tree.gd"

export(PoolIntArray) var nodes = PoolIntArray()


func _init(nodes_ = []) -> void:
	nodes = PoolIntArray(nodes_)
	resource_name = "Leaf"


func push_node(parent_index: int) -> void:
	nodes.append(parent_index)


func insert_node(position: int, parent_index: int) -> void:
	nodes.insert(position, parent_index)


func remove_node(parent_index: int) -> void:
	for i in nodes.size():
		if nodes[i] == parent_index:
			nodes.remove(i)
			return
	assert(false, "Remove failed, node %d was not found" % parent_index)


func empty() -> bool:
	return nodes.empty()


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
