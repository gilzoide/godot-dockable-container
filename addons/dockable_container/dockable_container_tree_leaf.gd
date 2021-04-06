extends "res://addons/dockable_container/dockable_container_tree.gd"

export(PoolIntArray) var nodes = PoolIntArray()

var parent = null


func _init(nodes_ = PoolIntArray()) -> void:
	nodes = nodes_
	resource_name = "Leaf"


func push_node(parent_index: int) -> void:
	nodes.append(parent_index)


func remove_node(parent_index: int) -> void:
	for i in nodes.size():
		if nodes[i] == parent_index:
			nodes.remove(i)
			emit_changed()
			break


func _ensure_indices_in_range(data: Dictionary):
	var from = data.from
	var to = data.to
	var i = 0
	var removed_once = false
	while i < nodes.size():
		var current = nodes[i]
		if current < from or current > to or data.has(current):
			nodes.remove(i)
			removed_once = true
		else:
			data[current] = self
			i += 1
	if not data.has("first"):
		data.first = self
