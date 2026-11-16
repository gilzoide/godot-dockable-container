@tool
extends EditorPlugin

const LayoutInspectorPlugin := preload("inspector_plugin/editor_inspector_plugin.gd")
const Icon := preload("icon.svg")

var _layout_inspector_plugin: LayoutInspectorPlugin

# Dynamic editor icon
var _is_icon_reimporting := false
var _last_processed_frame := 0


func _enter_tree() -> void:
	_layout_inspector_plugin = LayoutInspectorPlugin.new()
	add_custom_type("DockableContainer", "Container", DockableContainer, Icon)
	add_inspector_plugin(_layout_inspector_plugin)

	# Dynamic editor icon
	var base_ctl := EditorInterface.get_base_control()
	if not base_ctl.theme_changed.is_connected(_reimport_icon):
		base_ctl.theme_changed.connect(_reimport_icon)


func _exit_tree() -> void:
	remove_inspector_plugin(_layout_inspector_plugin)
	remove_custom_type("DockableContainer")
	_layout_inspector_plugin = null

	# Dynamic editor icon
	var base_ctl := EditorInterface.get_base_control()
	if base_ctl.theme_changed.is_connected(_reimport_icon):
		base_ctl.theme_changed.disconnect(_reimport_icon)


func _reimport_icon() -> void:
	# Frame-based debouncing
	if _is_icon_reimporting or Engine.get_process_frames() - _last_processed_frame <= 1:
		return
	_is_icon_reimporting = true

	# Other plugins may also want to do this; for comity, yield until FS has leisure
	var editor_tree := EditorInterface.get_base_control().get_tree()
	var fs := EditorInterface.get_resource_filesystem()
	while fs.is_scanning() or fs.is_importing():
		await editor_tree.process_frame
		if not is_inside_tree():
			_is_icon_reimporting = false
			return

	fs.reimport_files(PackedStringArray([Icon.resource_path]))
	_last_processed_frame = Engine.get_process_frames()
	_is_icon_reimporting = false
