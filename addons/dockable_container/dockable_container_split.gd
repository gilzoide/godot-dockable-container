tool
extends Control

signal changed()

enum Split {
	HORIZONTAL,
	VERTICAL,
}

const SPLIT_THEME_CLASS = [
	"HSplitContainer",  # SPLIT_THEME_CLASS[Split.HORIZONTAL]
	"VSplitContainer",  # SPLIT_THEME_CLASS[Split.VERTICAL]
]
var SPLIT_MOUSE_CURSOR_SHAPE = [
	CURSOR_HSPLIT,
	CURSOR_VSPLIT,
]

export(Split) var split = Split.HORIZONTAL setget set_split, get_split
export(float, 0, 1) var percent = 0.5 setget set_percent, get_percent

var _split = Split.HORIZONTAL
var _percent = 0.5
var _dragging = false


func _draw() -> void:
	var icon = get_icon("grabber", SPLIT_THEME_CLASS[_split])
	if not icon:
		return
	
	draw_texture(icon, (rect_size - icon.get_size()) * 0.5 )


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_dragging = event.is_pressed()
	elif event is InputEventMouseMotion and _dragging:
		var size = get_parent_control().rect_size
		if _split == Split.HORIZONTAL:
			set_percent((rect_position.x + event.position.x) / size.x)
		else:
			set_percent((rect_position.y + event.position.y) / size.y)


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		set_split_cursor(true)
	elif what == NOTIFICATION_MOUSE_EXIT:
		set_split_cursor(false)


func set_split(value: int) -> void:
	if value != _split:
		_split = value
		emit_signal("changed")


func get_split() -> int:
	return _split


func set_percent(value: float) -> void:
	var clamped_value = clamp(value, 0, 1)
	if not is_equal_approx(_percent, clamped_value):
		_percent = clamped_value
		emit_signal("changed")


func get_percent() -> float:
	return _percent


func set_split_cursor(value: bool) -> void:
	if value:
		mouse_default_cursor_shape = SPLIT_MOUSE_CURSOR_SHAPE[_split]
	else:
		mouse_default_cursor_shape = CURSOR_ARROW


func get_split_rects(rect: Rect2) -> Dictionary:
	var separation = get_constant("separation", SPLIT_THEME_CLASS[_split])
	var origin = rect.position
	var size = rect.size
	if _split == Split.HORIZONTAL:
		var first_width = (size.x - separation) * _percent
		var second_width = (size.x - separation) - first_width
		return {
			"first": Rect2(origin.x, origin.y, first_width, size.y),
			"self": Rect2(origin.x + first_width, origin.y, separation, size.y),
			"second": Rect2(origin.x + first_width + separation, origin.y, second_width, size.y),
		}
	else:
		var first_height = (size.y - separation) * _percent
		var second_height = (size.y - separation) - first_height
		return {
			"first": Rect2(origin.x, origin.y, size.x, first_height),
			"self": Rect2(origin.x, origin.y + first_height, size.x, separation),
			"second": Rect2(origin.x, origin.y + first_height + separation, size.x, second_height),
		}
