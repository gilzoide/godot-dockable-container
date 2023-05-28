extends Object
class_name DockableLayoutNode
## Common functionality for LayoutPanels and LayoutSplits


static func is_node(dict: Dictionary) -> bool:
	return DockableLayoutPanel.is_panel(dict) or DockableLayoutSplit.is_split(dict)


## Returns whether there are any nodes
static func is_empty(dict: Dictionary) -> bool:
	assert(is_node(dict))
	if DockableLayoutPanel.is_panel(dict):
		return DockableLayoutPanel.is_empty(dict)
	else:
		return DockableLayoutSplit.is_empty(dict)


## Returns all tab names in this node
static func get_names(dict: Dictionary) -> PackedStringArray:
	assert(is_node(dict))
	var names := PackedStringArray()
	populate_names(dict, names)
	return names


static func populate_names(dict: Dictionary, names: PackedStringArray) -> void:
	assert(is_node(dict))
	if DockableLayoutPanel.is_panel(dict):
		DockableLayoutPanel.populate_names(dict, names)
	else:
		DockableLayoutSplit.populate_names(dict, names)
