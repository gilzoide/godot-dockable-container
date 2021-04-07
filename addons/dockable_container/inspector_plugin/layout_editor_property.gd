extends EditorProperty

var background = ColorRect.new()

func _ready() -> void:
	rect_min_size = Vector2(128, 128)
	add_child(background)
	set_bottom_editor(background)
