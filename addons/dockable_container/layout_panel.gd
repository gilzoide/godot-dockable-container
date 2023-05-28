extends Object
class_name DockableLayoutPanel
## DockableLayout leaf nodes, defining tabs

const NAMES_KEY = "names"
const TAB_KEY = "tab"

static func create(names: PackedStringArray, tab: int) -> Dictionary:
	return {
		NAMES_KEY: names,
		TAB_KEY: tab,
	}


static func create_empty() -> Dictionary:
	return create(PackedStringArray(), 0)


static func is_panel(dict: Dictionary) -> bool:
	return dict.has_all([NAMES_KEY, TAB_KEY])


static func is_empty(dict: Dictionary) -> bool:
	assert(is_panel(dict))
	return get_names(dict).is_empty()


# Names operations
static func get_names(dict: Dictionary) -> PackedStringArray:
	assert(is_panel(dict))
	return dict[NAMES_KEY] as PackedStringArray


static func populate_names(dict: Dictionary, names: PackedStringArray) -> void:
	assert(is_panel(dict))
	names.append_array(get_names(dict))


static func push_name(dict: Dictionary, value: String) -> void:
	assert(is_panel(dict))
	dict[NAMES_KEY].append(value)


static func push_node(dict: Dictionary, value: Node) -> void:
	assert(is_panel(dict))
	push_name(dict, value.name)


static func insert_node(dict: Dictionary, position: int, value: Node) -> void:
	assert(is_panel(dict))
	dict[NAMES_KEY].insert(position, value.name)


static func find_name(dict: Dictionary, value: String) -> int:
	assert(is_panel(dict))
	return dict[NAMES_KEY].find(value)


static func find_node(dict: Dictionary, value: Node) -> int:
	assert(is_panel(dict))
	return find_name(dict, value.name)


static func remove_node(dict: Dictionary, value: Node) -> void:
	assert(is_panel(dict))
	var index: int = find_node(dict, value)
	if index >= 0:
		dict[NAMES_KEY].remove_at(index)
	else:
		push_warning("Remove failed, node '%s' was not found" % value)


static func rename_node(dict: Dictionary, previous_name: String, new_name: String) -> void:
	assert(is_panel(dict))
	var index: int = find_name(dict, previous_name)
	if index >= 0:
		dict[NAMES_KEY][index] = new_name
	else:
		push_warning("Rename failed, name '%s' was not found" % previous_name)


static func update_nodes(dict: Dictionary, out_node_names: PackedStringArray, out_dict: Dictionary) -> void:
	assert(is_panel(dict))
	var names := dict[NAMES_KEY] as PackedStringArray
	var i := 0
	while i < names.size():
		var name: String = names[i]
		if not name in out_node_names or out_dict.has(name):
			names.remove_at(i)
		else:
			out_dict[name] = dict
			i += 1


# Tab operations
static func get_tab(dict: Dictionary) -> int:
	assert(is_panel(dict))
	return clampi(dict.get(TAB_KEY, 0), 0, dict[NAMES_KEY].size())


static func set_tab(dict: Dictionary, value: int) -> void:
	assert(is_panel(dict))
	dict[TAB_KEY] = value
