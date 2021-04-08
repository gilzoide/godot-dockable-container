tool
extends "res://addons/dockable_container/layout_node.gd"
"""Layout leaf nodes, defining tabs"""

export(PoolStringArray) var names := PoolStringArray()
export(int) var current_tab: int setget set_current_tab, get_current_tab

var minimum_size: Vector2

var _current_tab := 0


func _init() -> void:
	resource_name = "Tabs"


func clone():
	var new_panel = get_script().new()
	new_panel.names = names
	new_panel._current_tab = _current_tab
	return new_panel


func push_name(name: String) -> void:
	names.append(name)


func insert_node(position: int, node: Node) -> void:
	names.insert(position, node.name)


func find_node(node: Node) -> int:
	var name = node.name
	for i in names.size():
		if names[i] == name:
			return i
	return -1


func remove_node(node: Node) -> void:
	var i = find_node(node)
	if i >= 0:
		names.remove(i)
	else:
		assert(false, "Remove failed, node '%s' was not found" % node)


func empty() -> bool:
	return names.empty()


func set_current_tab(value: int) -> void:
	_current_tab = clamp(value, 0, names.size() - 1)


func get_current_tab() -> int:
	return int(clamp(_current_tab, 0, names.size() - 1))


func get_minimum_size() -> Vector2:
	return minimum_size


func update_nodes(data: Dictionary):
	var node_names = data.names
	
	var i = 0
	while i < names.size():
		var current = names[i]
		if not current in node_names or data.has(current):
			names.remove(i)
		else:
			data[current] = self
			i += 1
	
	if not data.has("first"):
		data.first = self
