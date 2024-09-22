extends Node3D

@export var footstep_scene: PackedScene
@export var footstep_frequency: float = 0.5
@export var footstep_offset: float = 0.1
var cur_footstep: int = 1 # 1: right, -1: left
var snowy: bool = true

@onready var footstep_timer = %FootstepTimer
@onready var footstep_player = %FootstepPlayer
@onready var footstep_raycast = %FootstepRaycast

const V_OFFSET: float = 0.05
const FT_SOUND_PATH: String = "res://entities/player/\
footstep_generator/footstep_sounds.tres"
const SNOW_FT_SOUND_PATH: String = "res://entities/player/\
footstep_generator/snow_footstep_sounds.tres"


# Called when the node enters the scene tree for the first time.
func _ready():
	footstep_raycast.position = -2 * global_basis.x * footstep_offset
	footstep_timer.wait_time = footstep_frequency
	

func spawn_footstep():
	# Raycast query
	if not footstep_raycast.is_colliding():
		return
	
	footstep_player.play()
	
	if not snowy:
		return
	var collision_point: Vector3 = footstep_raycast.get_collision_point()
	var collision_normal: Vector3 = footstep_raycast.get_collision_normal()
	footstep_raycast.position *= -1
	
	var footstep_mark: Node3D = footstep_scene.instantiate()
	get_tree().root.add_child(footstep_mark)
	footstep_mark.global_position = collision_point + Vector3.UP * V_OFFSET
	footstep_mark.global_basis.y = collision_normal.normalized()
	footstep_mark.global_basis.x = global_basis.z.cross(collision_normal)
	footstep_mark.global_basis = footstep_mark.global_basis.orthonormalized()
	footstep_mark.scale.x *= cur_footstep
	footstep_mark.scale.z = -1
	cur_footstep *= -1


func start_motion(inside: bool):
	snowy = not inside
	if snowy:
		var ft_stream: AudioStreamRandomizer = ResourceLoader.load(\
		"res://entities/player/footstep_generator/snow_footstep_sounds.tres")
		footstep_player.stream = ft_stream
	else:
		var ft_stream: AudioStreamRandomizer = ResourceLoader.load(\
		"res://entities/player/footstep_generator/footstep_sounds.tres")
		footstep_player.stream = ft_stream
	footstep_timer.start()
	spawn_footstep()
	
	
func end_motion():
	footstep_timer.stop()


func _on_footstep_timer_timeout():
	spawn_footstep()
	footstep_timer.start()
