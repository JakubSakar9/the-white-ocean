extends Camera3D

@export var base_fov_degrees: float = 75

var focus_value: float = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	fov = base_fov_degrees / focus_value
