extends Node3D

var lifetime: float = 20.0
var time_left: float = lifetime

@onready var footstep_sprite = %FootstepSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_left -= delta
	if time_left < 0.0:
		queue_free()
	footstep_sprite.modulate = Color(1.0, 1.0, 1.0, time_left / lifetime)
	
