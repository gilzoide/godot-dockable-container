extends EditorProperty

const DockableContainer = preload("res://addons/dockable_container/dockable_container.gd")
const Layout = preload("res://addons/dockable_container/layout.gd")

var _container = DockableContainer.new()


func _ready() -> void:
	rect_min_size = Vector2(128, 256)
	
	_container.clone_layout_on_ready = false
	_container.rect_min_size = rect_min_size
	
	var original_container: DockableContainer = get_edited_object()
	var value = original_container.get(get_edited_property())
	_container.set(get_edited_property(), value)
	for n in value.get_names():
		var child = _create_child_control(n)
		_container.add_child(child)
	add_child(_container)
	set_bottom_editor(_container)


func update_property() -> void:
	var original_container: DockableContainer = get_edited_object()
	var value = original_container.get(get_edited_property())
	_container.set(get_edited_property(), value)


func _create_child_control(named: String) -> Control:
	var new_control = Label.new()
	new_control.name = named
	new_control.align = Label.ALIGN_CENTER
	new_control.valign = Label.VALIGN_CENTER
	new_control.clip_text = true
	new_control.text = named
	return new_control
