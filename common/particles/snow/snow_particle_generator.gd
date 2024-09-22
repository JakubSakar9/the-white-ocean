extends GPUParticles3D

func _physics_process(_delta):
	global_rotation = Vector3.ZERO

func change_wind(direction: Vector2, speed: float):
	var direction_aug: Vector2 = speed * direction.normalized()
	process_material.direction = Vector3(direction_aug.x, -1.0, direction_aug.y)
	process_material.initial_velocity_min = 0.9 * speed
	process_material.initial_velocity_max = 1.1 * speed
	process_material.emission_shape_offset = -process_material.direction.normalized() * speed
