"""
Layout Resources definition.

LayoutSplit are binary trees with nested LayoutSplit subtrees and LayoutPanel
leaves. Both of them inherit from LayoutNode to help with type annotation and
define common funcionality.
"""

const LayoutNode = preload("res://addons/dockable_container/layout_node.gd")
const LayoutPanel = preload("res://addons/dockable_container/layout_panel.gd")
const LayoutSplit = preload("res://addons/dockable_container/layout_split.gd")
