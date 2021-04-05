tool
extends Control

signal split_changed()
signal percent_changed()

enum Split {
	HORIZONTAL,
	VERTICAL,
}

const SPLIT_THEME_CLASS = [
	"HSplitContainer",  # SPLIT_THEME_CLASS[Split.HORIZONTAL]
	"VSplitContainer",  # SPLIT_THEME_CLASS[Split.VERTICAL]
]

export(Split) var split = Split.HORIZONTAL setget set_split, get_split
export(float, 0, 1) var percent = 0.5

var _split = Split.HORIZONTAL
var _percent = 0.5


func _draw() -> void:
	var icon = get_icon("grabber", SPLIT_THEME_CLASS[_split])
	if not icon:
		return
	
	draw_texture(icon, (rect_size - icon.get_size()) * 0.5 )


func set_split(value: int) -> void:
	_split = value
	emit_signal("split_changed")


func get_split() -> int:
	return _split


func set_percent(value: float) -> void:
	_percent = clamp(value, 0, 1)
	emit_signal("percent_changed")


func get_percent() -> float:
	return _percent


func get_split_rects(rect: Rect2) -> Dictionary:
	var separation = get_constant("separation", SPLIT_THEME_CLASS[_split])
	var origin = rect.position
	var size = rect.size
	if _split == Split.HORIZONTAL:
		var first_width = (size.x - separation) * percent
		var second_width = (size.x - separation) - first_width
		return {
			"first": Rect2(origin.x, origin.y, first_width, size.y),
			"self": Rect2(origin.x + first_width, origin.y, separation, size.y),
			"second": Rect2(origin.x + first_width + separation, origin.y, second_width, size.y),
		}
	else:
		var first_height = (size.y - separation) * percent
		var second_height = (size.y - separation) - first_height
		return {
			"first": Rect2(origin.x, origin.y, size.x, first_height),
			"self": Rect2(origin.x, origin.y + first_height, size.x, separation),
			"second": Rect2(origin.x, origin.y + first_height + separation, size.x, second_height),
		}
