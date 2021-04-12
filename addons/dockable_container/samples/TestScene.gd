extends VBoxContainer

const SAVED_LAYOUT_PATH = "user://layout.tres"

onready var _container = $DockableContainer
onready var _clone_control = $HBoxContainer/ControlPrefab


func _ready() -> void:
	if not OS.is_userfs_persistent():
		$HBoxContainer/SaveLayoutButton.visible = false
		$HBoxContainer/LoadLayoutButton.visible = false


func _on_add_pressed() -> void:
	var control = _clone_control.duplicate()
	control.get_node("Buttons/Rename").connect("pressed", self, "_on_control_rename_button_pressed", [control])
	control.get_node("Buttons/Remove").connect("pressed", self, "_on_control_remove_button_pressed", [control])
	control.color = Color(randf(), randf(), randf())
	control.name = "Control"
	
	_container.add_child(control, true)
	yield(_container, "sort_children")
	_container.set_control_as_current_tab(control)


func _on_save_pressed() -> void:
	if ResourceSaver.save(SAVED_LAYOUT_PATH, _container.get_layout()) != OK:
		print("ERROR")


func _on_load_pressed() -> void:
	var res = load(SAVED_LAYOUT_PATH)
	if res:
		_container.set_layout(res.clone())
	else:
		print("Error")


func _on_control_rename_button_pressed(control: Control) -> void:
	control.name += " =D"


func _on_control_remove_button_pressed(control: Control) -> void:
	_container.remove_child(control)
	control.queue_free()
