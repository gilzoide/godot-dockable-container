@tool
class_name DockableLayoutPanel
extends DockableLayoutNode
## DockableLayout leaf nodes, defining tabs

var names: PackedStringArray:
	get:
		return get_names()
	set(value):
		_names = value
var current_tab: int:
	get:
		return int(clamp(_current_tab, 0, _names.size() - 1))
	set(value):
		_current_tab = int(clamp(value, 0, _names.size() - 1))

var _names := PackedStringArray()
var _current_tab := 0


## Returns all tab names in this node
func get_names() -> PackedStringArray:
	return _names


func push_name(name: String) -> void:
	_names.append(name)


func insert_node(position: int, node: Node) -> void:
	_names.insert(position, node.name)


func find_name(node_name: String) -> int:
	for i in _names.size():
		if _names[i] == node_name:
			return i
	return -1


func find_child(node: Node) -> int:
	return find_name(node.name)


func remove_node(node: Node) -> void:
	var i := find_child(node)
	if i >= 0:
		_names.remove_at(i)
	else:
		push_warning("Remove failed, node '%s' was not found" % node)


func rename_node(previous_name: String, new_name: String) -> void:
	var i := find_name(previous_name)
	if i >= 0:
		_names.set(i, new_name)
	else:
		push_warning("Rename failed, name '%s' was not found" % previous_name)


## Returns whether there are any nodes
func is_empty() -> bool:
	return _names.is_empty()


func update_nodes(node_names: PackedStringArray, data: Dictionary) -> void:
	var i := 0
	while i < _names.size():
		var current := _names[i]
		if not current in node_names or data.has(current):
			_names.remove_at(i)
		else:
			data[current] = self
			i += 1


func to_dict() -> Dictionary:
	return {
		names = _names.duplicate(),
		current_tab = _current_tab,
	}


static func from_dict(dict: Dictionary) -> DockableLayoutNode:
	var panel := DockableLayoutPanel.new()
	panel.names = dict["names"].duplicate()
	panel.current_tab = dict.get("current_tab", 0)
	return panel
