@tool
class_name DockableLayoutNode
extends RefCounted
## Base class for DockableLayout tree nodes

var parent: DockableLayoutSplit:
	get:
		return _parent_ref.get_ref()
	set(value):
		_parent_ref = weakref(value)

var _parent_ref := WeakRef.new()


## Returns whether there are any nodes
func is_empty() -> bool:
	return true


## Returns all tab names in this node
func get_names() -> PackedStringArray:
	return PackedStringArray()


## Serialize layout node to Dictionary
func to_dict() -> Dictionary:
	return {}


## Deserialize Dictionary to layout node
static func from_dict(dict: Dictionary) -> DockableLayoutNode:
	if dict.has("names"):
		return DockableLayoutPanel.from_dict(dict)
	elif dict.has_all(["first", "second"]):
		return DockableLayoutSplit.from_dict(dict)
	else:
		return null
