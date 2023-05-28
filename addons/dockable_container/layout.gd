@tool
class_name DockableLayout
extends Resource
## DockableLayout Resource definition, holding the root DockableLayoutNode and hidden tabs.
##
## DockableLayoutSplit are binary trees with nested DockableLayoutSplit subtrees
## and DockableLayoutPanel leaves. Both of them inherit from DockableLayoutNode to help with
## type annotation and define common functionality.
##
## Hidden tabs are marked in the `hidden_tabs` Dictionary by name.

enum { MARGIN_LEFT, MARGIN_RIGHT, MARGIN_TOP, MARGIN_BOTTOM, MARGIN_CENTER }

@export var root: Dictionary = {}:
	get:
		return get_root()
	set(value):
		set_root(value)
@export var hidden_tabs: Dictionary = {}:
	get:
		return _hidden_tabs
	set(value):
		if value != _hidden_tabs:
			_hidden_tabs = value
			changed.emit()

var _changed_signal_queued := false
var _first_leaf: Dictionary
var _hidden_tabs: Dictionary
var _leaf_by_node_name: Dictionary
var _root: Dictionary
var _node_parents: Dictionary


func _init() -> void:
	resource_name = "Layout"


func set_root(value: Dictionary, should_emit_changed := true) -> void:
	if not DockableLayoutNode.is_node(value):
		value = DockableLayoutPanel.create_empty()
	
	_root = value
	_node_parents.erase(value)
	if should_emit_changed:
		_on_root_changed()


func get_root() -> Dictionary:
	return _root


func clone() -> DockableLayout:
	return duplicate(true)


func get_names() -> PackedStringArray:
	return DockableLayoutNode.get_names(_root)


## Add missing nodes on first leaf and remove nodes outside indices from leaves.
##
## _leaf_by_node_name = {
##     (string keys) = respective Leaf that holds the node name,
## }
func update_nodes(names: PackedStringArray) -> void:
	_leaf_by_node_name.clear()
	_node_parents.clear()
	_first_leaf = {}
	var empty_leaves: Array[Dictionary] = []
	_ensure_names_in_node(_root, names, empty_leaves)  # Changes _leaf_by_node_name, empty_leaves and _node_parents
	for l in empty_leaves:
		_remove_leaf(l)
	if not DockableLayoutPanel.is_panel(_first_leaf):
		_first_leaf = DockableLayoutPanel.create_empty()
		set_root(_first_leaf)
	for n in names:
		if not _leaf_by_node_name.has(n):
			DockableLayoutPanel.push_name(_first_leaf, n)
			_leaf_by_node_name[n] = _first_leaf
	_on_root_changed()


func move_node_to_leaf(node: Node, leaf: Dictionary, relative_position: int) -> void:
	var node_name := node.name
	var previous_leaf := _leaf_by_node_name.get(node_name, {}) as Dictionary
	if DockableLayoutPanel.is_panel(previous_leaf):
		DockableLayoutPanel.remove_node(previous_leaf, node)
		if DockableLayoutPanel.is_empty(previous_leaf):
			_remove_leaf(previous_leaf)
	
	DockableLayoutPanel.insert_node(leaf, relative_position, node)
	_leaf_by_node_name[node_name] = leaf
	_on_root_changed()


func get_leaf_for_node(node: Node) -> Dictionary:
	return _leaf_by_node_name.get(node.name, {}) as Dictionary


func split_leaf_with_node(leaf: Dictionary, node: Node, margin: int) -> void:
	var root_branch := _node_parents.get(leaf, {}) as Dictionary
	var new_leaf := DockableLayoutPanel.create_empty()
	var direction = (
		DockableLayoutSplit.Direction.HORIZONTAL
		if margin == MARGIN_LEFT or margin == MARGIN_RIGHT
		else DockableLayoutSplit.Direction.VERTICAL
	)
	var first = new_leaf if margin == MARGIN_LEFT or margin == MARGIN_TOP else leaf
	var second = leaf if margin == MARGIN_LEFT or margin == MARGIN_TOP else new_leaf
	
	var new_branch := DockableLayoutSplit.create(direction, 0.5, first, second)
	_node_parents[leaf] = new_branch
	_node_parents[new_leaf] = new_branch
	
	if _root == leaf:
		set_root(new_branch, false)
	elif DockableLayoutSplit.is_split(root_branch):
		if DockableLayoutSplit.get_first(root_branch) == leaf:
			DockableLayoutSplit.set_first(root_branch, new_branch)
		else:
			DockableLayoutSplit.set_second(root_branch, new_branch)
		_node_parents[new_branch] = root_branch
	move_node_to_leaf(node, new_leaf, 0)


func add_node(node: Node) -> void:
	var node_name := node.name
	if _leaf_by_node_name.has(node_name):
		return
	DockableLayoutPanel.push_name(_first_leaf, node_name)
	_leaf_by_node_name[node_name] = _first_leaf
	_on_root_changed()


func remove_node(node: Node) -> void:
	var node_name := node.name
	var leaf := _leaf_by_node_name.get(node_name, {}) as Dictionary
	if not DockableLayoutPanel.is_panel(leaf):
		return
	DockableLayoutPanel.remove_node(leaf, node)
	_leaf_by_node_name.erase(node_name)
	if DockableLayoutPanel.is_empty(leaf):
		_remove_leaf(leaf)
	_on_root_changed()


func rename_node(previous_name: String, new_name: String) -> void:
	var leaf := _leaf_by_node_name.get(previous_name, {}) as Dictionary
	if not DockableLayoutPanel.is_panel(leaf):
		return
	DockableLayoutPanel.rename_node(leaf, previous_name, new_name)
	_leaf_by_node_name.erase(previous_name)
	_leaf_by_node_name[new_name] = leaf
	_on_root_changed()


func set_tab_hidden(name: String, hidden: bool) -> void:
	if not _leaf_by_node_name.has(name):
		return
	if hidden:
		_hidden_tabs[name] = true
	else:
		_hidden_tabs.erase(name)
	_on_root_changed()


func is_tab_hidden(name: String) -> bool:
	return _hidden_tabs.get(name, false)


func set_node_hidden(node: Node, hidden: bool) -> void:
	set_tab_hidden(node.name, hidden)


func is_node_hidden(node: Node) -> bool:
	return is_tab_hidden(node.name)


func _on_root_changed() -> void:
	if _changed_signal_queued:
		return
	_changed_signal_queued = true
	set_deferred("_changed_signal_queued", false)
	emit_changed.call_deferred()


func _ensure_names_in_node(
	node: Dictionary, names: PackedStringArray, empty_leaves: Array[Dictionary]
) -> void:
	if DockableLayoutPanel.is_panel(node):
		DockableLayoutPanel.update_nodes(node, names, _leaf_by_node_name)  # This changes _leaf_by_node_name
		if DockableLayoutPanel.is_empty(node):
			empty_leaves.append(node)
		elif not DockableLayoutPanel.is_panel(_first_leaf):
			_first_leaf = node
	elif DockableLayoutSplit.is_split(node):
		var first = DockableLayoutSplit.get_first(node)
		var second = DockableLayoutSplit.get_second(node)
		_node_parents[first] = node
		_node_parents[second] = node
		_ensure_names_in_node(first, names, empty_leaves)
		_ensure_names_in_node(second, names, empty_leaves)
	else:
		@warning_ignore("assert_always_false")
		assert(false, "Invalid Resource, should be branch or leaf, found %s" % node)


func _remove_leaf(leaf: Dictionary) -> void:
	assert(DockableLayoutPanel.is_empty(leaf), "FIXME: trying to remove_at a leaf with nodes")
	if _root == leaf:
		return
	var collapsed_branch := _node_parents.get(leaf, {}) as Dictionary
	assert(DockableLayoutSplit.is_split(collapsed_branch), "FIXME: leaf is not a child of branch")
	var kept_branch: Dictionary = (
		DockableLayoutSplit.get_first(collapsed_branch)
		if leaf == DockableLayoutSplit.get_second(collapsed_branch)
		else DockableLayoutSplit.get_second(collapsed_branch)
	)
	var root_branch := _node_parents.get(collapsed_branch, {}) as Dictionary
	if collapsed_branch == _root:
		set_root(kept_branch, true)
	elif DockableLayoutSplit.is_split(root_branch):
		if DockableLayoutSplit.get_first(root_branch) == collapsed_branch:
			DockableLayoutSplit.set_first(root_branch, kept_branch)
		else:
			DockableLayoutSplit.set_second(root_branch, kept_branch)
		_node_parents[kept_branch] = root_branch
	_node_parents.erase(leaf)
	_node_parents.erase(collapsed_branch)
	_on_root_changed()


func _print_tree() -> void:
	print("TREE")
	_print_tree_step(root, 0, 0)
	print("")


func _print_tree_step(tree_or_leaf: Dictionary, level: int, idx: int) -> void:
	if DockableLayoutPanel.is_panel(tree_or_leaf):
		print(" |".repeat(level), "- (%d) = " % idx, DockableLayoutPanel.get_names(tree_or_leaf))
	elif DockableLayoutSplit.is_split(tree_or_leaf):
		print(
			" |".repeat(level),
			"-+ (%d) = " % idx,
			DockableLayoutSplit.get_direction(tree_or_leaf),
			" ",
			DockableLayoutSplit.get_percent(tree_or_leaf)
		)
		_print_tree_step(DockableLayoutSplit.get_first(tree_or_leaf), level + 1, 1)
		_print_tree_step(DockableLayoutSplit.get_second(tree_or_leaf), level + 1, 2)
