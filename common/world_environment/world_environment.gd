extends WorldEnvironment

@export var base_fog_density = 0.15
@export var view_distance = 25.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var density = base_fog_density
	environment.fog_density = density

