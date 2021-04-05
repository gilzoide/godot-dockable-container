extends Reference
class_name DockableContainerTree

enum Split {
	HORIZONTAL,
	VERTICAL,
}

export(PoolStringArray) var node_names := PoolStringArray()
export(Split) var split := Split.HORIZONTAL
export(float) var split_percent := 0.5
var next: DockableContainerTree = null


