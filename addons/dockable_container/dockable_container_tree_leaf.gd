extends Resource

export(PoolIntArray) var nodes = PoolIntArray()

func _init(nodes_ = PoolIntArray()) -> void:
	nodes = nodes_
	resource_name = "Leaf"
