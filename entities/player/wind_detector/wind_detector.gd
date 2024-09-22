extends Node3D

@export var detection_range: float  = 10.0
@export var max_wind_reduction: float = 1.0

var wind: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	wind = get_tree().get_first_node_in_group("wind")
	for raycast: RayCast3D in get_children():
		raycast.target_position = raycast.target_position.normalized() * detection_range


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if wind == null:
		return
	var direction_n: Vector2 = wind.direction.normalized()
	global_rotation = Vector3(0, direction_n.angle_to(Vector2.LEFT), 0)
	var reduction: float = 0.0
	for raycast: RayCast3D in get_children():
		if raycast.is_colliding(): 
			# Get distance from the collision point and normalize relative to raycast length
			var d: float = raycast.get_collision_point().distance_to(global_position)
			# d /= detection_range
			d /= raycast.target_position.length()
			# Rename for convenience
			var m: float = max_wind_reduction
			# Calculate the reduction
			reduction += m * d ** 2 - 2 * m * d + m
	reduction /= get_child_count()
	reduction = pow(reduction, 1.5)
	wind.reduction = reduction
