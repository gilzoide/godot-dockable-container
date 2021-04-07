extends Control

signal changed()

const SPLIT_THEME_CLASS = [
	"HSplitContainer",  # SPLIT_THEME_CLASS[MARGIN_LEFT]
	"VSplitContainer",  # SPLIT_THEME_CLASS[MARGIN_TOP]
	"HSplitContainer",  # SPLIT_THEME_CLASS[MARGIN_RIGHT]
	"VSplitContainer",  # SPLIT_THEME_CLASS[MARGIN_BOTTOM]
]

const SPLIT_MOUSE_CURSOR_SHAPE = [
	Control.CURSOR_HSPLIT,  # SPLIT_MOUSE_CURSOR_SHAPE[MARGIN_LEFT]
	Control.CURSOR_VSPLIT,  # SPLIT_MOUSE_CURSOR_SHAPE[MARGIN_TOP]
	Control.CURSOR_HSPLIT,  # SPLIT_MOUSE_CURSOR_SHAPE[MARGIN_RIGHT]
	Control.CURSOR_VSPLIT,  # SPLIT_MOUSE_CURSOR_SHAPE[MARGIN_BOTTOM]
]

var split_tree setget set_split_tree, get_split_tree

var _parent_rect
var _split_tree
var _mouse_hovering = false
var _dragging = false


func _draw() -> void:
	var theme_class = SPLIT_THEME_CLASS[_split_tree.split]
	var icon = get_icon("grabber", theme_class)
	var autohide = bool(get_constant("autohide", theme_class))
	if not icon or (autohide and not _mouse_hovering):
		return
	
	draw_texture(icon, (rect_size - icon.get_size()) * 0.5 )


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_dragging = event.is_pressed()
	elif Engine.editor_hint and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and not event.is_pressed():
		_split_tree.percent = 0.5
	elif event is InputEventMouseMotion and _dragging:
		var mouse_in_parent = get_parent_control().get_local_mouse_position()
		if _split_tree.is_horizontal():
			_split_tree.percent = (mouse_in_parent.x - _parent_rect.position.x) / _parent_rect.size.x
		else:
			_split_tree.percent = (mouse_in_parent.y - _parent_rect.position.y) / _parent_rect.size.y


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_mouse_hovering = true
		set_split_cursor(true)
		if bool(get_constant("autohide", SPLIT_THEME_CLASS[_split_tree.split])):
			update()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_mouse_hovering = false
		set_split_cursor(false)
		if bool(get_constant("autohide", SPLIT_THEME_CLASS[_split_tree.split])):
			update()
	elif what == NOTIFICATION_FOCUS_EXIT:
		_dragging = false


func set_split_tree(value):
	_split_tree = value


func get_split_tree():
	return _split_tree


func set_split_cursor(value: bool) -> void:
	if value:
		mouse_default_cursor_shape = SPLIT_MOUSE_CURSOR_SHAPE[_split_tree.split]
	else:
		mouse_default_cursor_shape = CURSOR_ARROW


func get_split_rects(rect: Rect2) -> Dictionary:
	_parent_rect = rect
	var separation = get_constant("separation", SPLIT_THEME_CLASS[_split_tree.split])
	var origin = rect.position
	var size = rect.size
	var percent = _split_tree.percent
	if _split_tree.is_horizontal():
		var first_width = (size.x - separation) * percent
		var second_width = (size.x - separation) - first_width
		var left = Rect2(origin.x, origin.y, first_width, size.y)
		var right = Rect2(origin.x + first_width + separation, origin.y, second_width, size.y)
		return {
			"first": left if _split_tree.split == MARGIN_RIGHT else right,
			"self": Rect2(origin.x + first_width, origin.y, separation, size.y),
			"second": right if _split_tree.split == MARGIN_RIGHT else left,
		}
	else:
		var first_height = (size.y - separation) * percent
		var second_height = (size.y - separation) - first_height
		var top = Rect2(origin.x, origin.y, size.x, first_height)
		var bottom = Rect2(origin.x, origin.y + first_height + separation, size.x, second_height)
		return {
			"first": top if _split_tree.split == MARGIN_BOTTOM else bottom,
			"self": Rect2(origin.x, origin.y + first_height, size.x, separation),
			"second": bottom if _split_tree.split == MARGIN_BOTTOM else top,
		}
