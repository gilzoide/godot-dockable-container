# Dockable Container
Docking panels Container addon for [Godot](https://godotengine.org/).

![](screenshots/video1.gif)

It is composed of a Container script and tree-shaped layout Resources that
store panels division direction and size as well as tab indices and what tab is
currently selected.

Child Controls are only moved visually and and have their NodePaths and order maintained.


## Theming
Panels are actual TabContainer instances, split handles use VSplitContainer and
HSplitContainer theme configurations, drop preview uses TooltipPanel `panel` StyleBox.
Tabs alignment and rearrange group are exported in DockableContainer.


## TODO
- Add way to specify icon and custom name for tabs, based on a property or method on children
- Document how to use
- Web build on GitHub pages and link here on README
- Add custom editor for layout Resources

