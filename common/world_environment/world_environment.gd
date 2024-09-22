extends WorldEnvironment

@export var base_fog_density = 0.5
@export var view_distance = 15


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	environment.fog_density = base_fog_density
	pass
