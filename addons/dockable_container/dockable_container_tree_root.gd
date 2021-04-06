extends Resource

const DockableContainerTreeNode = preload("res://addons/dockable_container/dockable_container_tree.gd")
const DockableContainerTreeBranch = preload("res://addons/dockable_container/dockable_container_tree_branch.gd")
const DockableContainerTreeLeaf = preload("res://addons/dockable_container/dockable_container_tree_leaf.gd")

var parent setget , get_parent
var root setget set_root, get_root
var data: Dictionary

var _root: DockableContainerTreeNode


func set_root(value: DockableContainerTreeNode) -> void:
	_root = value
	_root.parent = self


func get_root() -> DockableContainerTreeNode:
	return _root


func get_parent():
	return null


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
	data = { from = from, to = to }
	_root._ensure_indices_in_range(data)
	var first = data.first
	assert(first, "FIXME: no leaves were found in tree")
	for i in range(from, to + 1):
		if not data.has(i):
			first.push_node(i)
			data[i] = first


func move_node_to_leaf(node_index: int, leaf, relative_position: int) -> void:
	var previous_leaf = data[node_index]
	previous_leaf.remove_node(node_index)
	if previous_leaf.empty():
		# TODO: merge parent branch
		pass
	
	leaf.insert_node(relative_position, node_index)
	data[node_index] = leaf


func split_leaf_with_node(leaf, node_index: int, margin: int) -> void:
	var previous_leaf = data[node_index]
	previous_leaf.remove_node(node_index)
	if previous_leaf.empty():
		# TODO: merge parent branch
		pass
	
	var previous_parent = leaf.parent
	var new_leaf = DockableContainerTreeLeaf.new([node_index])
	var new_branch = DockableContainerTreeBranch.new()
	new_branch.split = margin
	if previous_parent == self:
		self.root = new_branch
	else:
		if leaf == previous_parent.first:
			previous_parent.first = new_branch
		elif leaf == previous_parent.second:
			previous_parent.second = new_branch
	new_branch.first = leaf
	new_branch.second = new_leaf
	data[node_index] = new_leaf
	_print_tree()
	emit_changed()


func _print_tree() -> void:
	print("TREE")
	_print_tree_step(_root, 0)
	print("")


func _print_tree_step(tree_or_leaf, level) -> void:
	if tree_or_leaf is DockableContainerTreeLeaf:
		print("  ".repeat(level), "+ ", tree_or_leaf.nodes)
	else:
		print("  ".repeat(level + 1), "\\ ", tree_or_leaf.split, " ", tree_or_leaf.percent)
		_print_tree_step(tree_or_leaf.first, level + 1)
		_print_tree_step(tree_or_leaf.second, level + 1)
