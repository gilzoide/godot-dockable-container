extends Button

export(NodePath) var container_path

onready var _container = get_node(container_path)

func _pressed() -> void:
	var control = ColorRect.new()
	control.color = Color(randf(), randf(), randf())
	control.name = "Control"
	_container.add_child(control, true)
	_container.call_deferred("set_control_as_current_tab", control)
