extends Area3D

@export var message: String
@export var follow_up: Area3D


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.display_message(message)
		if follow_up != null:
			follow_up.monitoring = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		body.end_message()
		queue_free()
