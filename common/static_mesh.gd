extends GeometryInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var env: Node = get_tree().get_first_node_in_group("environment")
	if env != null:
		visibility_range_end = env.view_distance
