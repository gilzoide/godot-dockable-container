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
	emit_signal("changed")


func insert_node(position: int, node: Node) -> void:
	names.insert(position, node.name)
	emit_signal("changed")


func find_name(node_name: String) -> int:
	for i in names.size():
		if names[i] == node_name:
			return i
	return -1


func find_node(node: Node):
	return find_name(node.name)


func remove_node(node: Node) -> void:
	var i = find_node(node)
	if i >= 0:
		names.remove(i)
		emit_signal("changed")
	else:
		push_warning("Remove failed, node '%s' was not found" % node)


func rename_node(previous_name: String, new_name: String) -> void:
	var i = find_name(previous_name)
	if i >= 0:
		names.set(i, new_name)
		emit_signal("changed")
	else:
		push_warning("Rename failed, name '%s' was not found" % previous_name)


func empty() -> bool:
	return names.empty()


func set_current_tab(value: int) -> void:
	_current_tab = clamp(value, 0, names.size() - 1)
	emit_signal("changed")


func get_current_tab() -> int:
	return int(clamp(_current_tab, 0, names.size() - 1))


func get_minimum_size() -> Vector2:
	return minimum_size


func update_nodes(node_names: PoolStringArray, data: Dictionary):
	var i = 0
	var removed_any = false
	while i < names.size():
		var current = names[i]
		if not current in node_names or data.has(current):
			names.remove(i)
			removed_any = true
		else:
			data[current] = self
			i += 1
	if removed_any:
		emit_signal("changed")
