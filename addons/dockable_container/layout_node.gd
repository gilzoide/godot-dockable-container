tool
extends Resource
"""Base class for Layout tree nodes"""

var parent = null


func emit_tree_changed() -> void:
	var node = self
	while node:
		node.emit_signal("changed")
		node = node.parent


func clone():
	"""
	Returns a deep copy of the layout.
	
	Use this instead of `Resource.duplicate(true)` to ensure objects have the
	right script and parenting is correctly set for each node.
	"""
	assert("FIXME: implement on child")


func empty() -> bool:
	"""Returns whether there are any nodes"""
	assert("FIXME: implement on child")
	return true


func get_names() -> PoolStringArray:
	"""Returns all tab names in this node"""
	assert("FIXME: implement on child")
	return PoolStringArray()
