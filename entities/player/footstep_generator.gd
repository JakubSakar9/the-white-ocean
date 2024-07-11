extends Node3D

@export var footstep_scene: PackedScene
@export var footstep_frequency: float = 0.5
@export var footstep_offset: float = 0.1
var cur_footstep: int = 1 # 1: right, -1: left

@onready var footstep_timer = %FootstepTimer
@onready var footstep_player = $FootstepPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	footstep_timer.wait_time = footstep_frequency
	

func spawn_footstep():
	var footstep_mark: Node3D = footstep_scene.instantiate()
	get_tree().root.add_child(footstep_mark)
	var side_offset = global_basis.x * footstep_offset * cur_footstep
	footstep_mark.global_position = global_position - side_offset
	footstep_mark.global_rotation = global_rotation
	footstep_mark.scale.x *= cur_footstep
	cur_footstep *= -1
	footstep_player.play()


func start_motion():
	footstep_timer.start()
	spawn_footstep()
	
	
func end_motion():
	footstep_timer.stop()


func _on_footstep_timer_timeout():
	spawn_footstep()
	footstep_timer.start()
