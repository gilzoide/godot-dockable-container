extends Object
class_name DockableLayoutSplit

## DockableLayout binary tree nodes, defining subtrees and leaf panels
const DIRECTION_KEY = "direction"
const PERCENT_KEY = "percent"
const FIRST_KEY = "first"
const SECOND_KEY = "second"

enum Direction { HORIZONTAL, VERTICAL }

static func create(direction: Direction, percent: float, first: Dictionary, second: Dictionary) -> Dictionary:
	return {
		DIRECTION_KEY: direction,
		PERCENT_KEY: percent,
		FIRST_KEY: first,
		SECOND_KEY: second,
	}


static func is_split(dict: Dictionary) -> bool:
	return dict.has_all([DIRECTION_KEY, PERCENT_KEY, FIRST_KEY, SECOND_KEY])


static func is_empty(dict: Dictionary) -> bool:
	assert(is_split(dict))
	return DockableLayoutNode.is_empty(get_first(dict)) and DockableLayoutNode.is_empty(get_second(dict))


static func populate_names(dict: Dictionary, names: PackedStringArray) -> void:
	assert(is_split(dict))
	DockableLayoutNode.populate_names(get_first(dict), names)
	DockableLayoutNode.populate_names(get_second(dict), names)


# Direction operations
static func get_direction(dict: Dictionary) -> Direction:
	assert(is_split(dict))
	return dict.get(DIRECTION_KEY, Direction.HORIZONTAL) as Direction


static func set_direction(dict: Dictionary, value: Direction) -> void:
	assert(is_split(dict))
	dict[DIRECTION_KEY] = value


static func is_horizontal(dict: Dictionary) -> bool:
	return get_direction(dict) == Direction.HORIZONTAL


static func is_vertical(dict: Dictionary) -> bool:
	return get_direction(dict) == Direction.VERTICAL


# Percent operations
static func get_percent(dict: Dictionary) -> float:
	assert(is_split(dict))
	return dict.get(PERCENT_KEY, 0.5) as float


static func set_percent(dict: Dictionary, value: float) -> void:
	assert(is_split(dict))
	dict[PERCENT_KEY] = clampf(value, 0, 1)


# First operations
static func get_first(dict: Dictionary) -> Dictionary:
	assert(is_split(dict))
	return dict[FIRST_KEY] as Dictionary


static func set_first(dict: Dictionary, value: Dictionary) -> void:
	assert(is_split(dict))
	if not DockableLayoutNode.is_node(value):
		value = DockableLayoutPanel.create_empty()
	dict[FIRST_KEY] = value


# Second operations
static func get_second(dict: Dictionary) -> Dictionary:
	assert(is_split(dict))
	return dict[SECOND_KEY] as Dictionary


static func set_second(dict: Dictionary, value: Dictionary) -> void:
	assert(is_split(dict))
	if not DockableLayoutNode.is_node(value):
		value = DockableLayoutPanel.create_empty()
	dict[SECOND_KEY] = value
