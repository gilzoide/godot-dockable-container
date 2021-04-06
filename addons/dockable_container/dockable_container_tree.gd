tool
extends Resource


func ensure_indices_in_range(from: int, to: int):
	"""
	Add nodes in range on first leaf, if missing, and remove nodes outside
	range from leaves.
	
	Returns: {
		from = from,
		to = to,
		(numeric keys) from ... to = respective Leaf that holds the node index,
		first = first leaf,
	}
	"""
	var data = { from = from, to = to }
	_ensure_indices_in_range(data)
	var first = data.first
	assert(first, "FIXME: no leaves were found in tree")
	for i in range(from, to + 1):
		if not data.has(i):
			first.push_node(i)
			data[i] = first
	return data


func _ensure_indices_in_range(data: Dictionary) -> void:
	assert("FIXME: implement on child")
