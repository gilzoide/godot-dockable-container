tool
extends Reference

signal changed()

const Layout = preload("res://addons/dockable_container/layout.gd")

export(Resource) var root = Layout.LayoutPanel.new() setget set_root, get_root
var parent setget , get_parent

var _data: Dictionary
var _root: Layout.LayoutNode
var _first_leaf: Layout.LayoutPanel


func set_root(value: Layout.LayoutNode, should_emit_changed = true) -> void:
	if not value:
		value = Layout.LayoutPanel.new()
	_root = value
	_root.parent = self
	if should_emit_changed:
		emit_signal("changed")


func get_root() -> Layout.LayoutNode:
	return _root


func get_parent():
	return null


func update_nodes(names: PoolStringArray) -> void:
	"""
	Add missing nodes on first leaf and remove nodes outside indices from leaves.
	
	_data = {
		(string keys) = respective Leaf that holds the node name,
	}
	"""
	_data = {}
	_first_leaf = null
	var empty_leaves = []
	_ensure_names_in_node(_root, names, empty_leaves)
	for l in empty_leaves:
		_remove_leaf(l)
	if not _first_leaf:
		_first_leaf = Layout.LayoutPanel.new()
		root = _first_leaf
	for n in names:
		if not _data.has(n):
			_first_leaf.push_name(n)
			_data[n] = _first_leaf
	emit_signal("changed")


func move_node_to_leaf(node: Node, leaf: Layout.LayoutPanel, relative_position: int) -> void:
	var node_name = node.name
	var previous_leaf = _data.get(node_name)
	if not previous_leaf:
		return
	previous_leaf.remove_node(node)
	if previous_leaf.empty():
		_remove_leaf(previous_leaf)
	
	leaf.insert_node(relative_position, node)
	_data[node_name] = leaf
#	_print_tree()
	emit_signal("changed")


func get_leaf_for_node(node: Node) -> Layout.LayoutPanel:
	return _data.get(node.name)


func split_leaf_with_node(leaf, node: Node, margin: int) -> void:
	var root_branch = leaf.parent
	var new_leaf = Layout.LayoutPanel.new()
	var new_branch = Layout.LayoutSplit.new()
	new_branch.split = margin
	new_branch.first = leaf
	new_branch.second = new_leaf
	if root_branch == self:
		self.root = new_branch
	elif leaf == root_branch.first:
		root_branch.first = new_branch
	else:
		root_branch.second = new_branch
	
	move_node_to_leaf(node, new_leaf, 0)


func add_node(node: Node) -> void:
	var node_name = node.name
	if _data.has(node_name):
		return
	_first_leaf.push_name(node_name)
	_data[node_name] = _first_leaf
	emit_signal("changed")


func remove_node(node: Node) -> void:
	var node_name = node.name
	var leaf: Layout.LayoutPanel = _data.get(node_name)
	if not leaf:
		return
	leaf.remove_node(node)
	_data.erase(node_name)
	if leaf.empty():
		_remove_leaf(leaf)
	emit_signal("changed")


func rename_node(previous_name: String, new_name: String) -> void:
	var leaf = _data.get(previous_name)
	if not leaf:
		return
	leaf.rename_node(previous_name, new_name)
	_data.erase(previous_name)
	_data[new_name] = leaf
	emit_signal("changed")


func split_parameters_changed() -> void:
	emit_signal("changed")


func _ensure_names_in_node(node: Layout.LayoutNode, names: PoolStringArray, empty_leaves: Array) -> void:
	if node is Layout.LayoutPanel:
		node.update_nodes(names, _data)
		if node.empty():
			empty_leaves.append(node)
		if not _first_leaf:
			_first_leaf = node
	elif node is Layout.LayoutSplit:
		_ensure_names_in_node(node.first, names, empty_leaves)
		_ensure_names_in_node(node.second, names, empty_leaves)
	else:
		assert(false, "Invalid Resource, should be branch or leaf, found %s" % node)


func _remove_leaf(leaf: Layout.LayoutPanel) -> void:
	assert(leaf.empty(), "FIXME: trying to remove a leaf with nodes")
	var collapsed_branch = leaf.parent
	if collapsed_branch == self:
		return
	assert(collapsed_branch is Layout.LayoutSplit, "FIXME: leaf is not a child of branch")
	var kept_branch = collapsed_branch.first if leaf == collapsed_branch.second else collapsed_branch.second
	var root_branch = collapsed_branch.parent
	if root_branch == self:
		self.root = kept_branch
	elif collapsed_branch == root_branch.first:
		root_branch.first = kept_branch
	else:
		root_branch.second = kept_branch


func _print_tree() -> void:
	print("TREE")
	_print_tree_step(_root, 0, 0)
	print("")


func _print_tree_step(tree_or_leaf, level, idx) -> void:
	if tree_or_leaf is Layout.LayoutPanel:
		print(" |".repeat(level), "- (%d) = " % idx, tree_or_leaf.names)
	else:
		print(" |".repeat(level), "-+ (%d) = " % idx, tree_or_leaf.split, " ", tree_or_leaf.percent)
		_print_tree_step(tree_or_leaf.first, level + 1, 1)
		_print_tree_step(tree_or_leaf.second, level + 1, 2)
