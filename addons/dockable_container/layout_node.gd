tool
extends Resource
"""Base class for Layout tree nodes"""

var parent = null


func get_root():
	var last = self
	while last.parent:
		last = last.parent
	return last


func _ensure_indices_in_range(data: Dictionary) -> void:
	assert("FIXME: implement on child")
