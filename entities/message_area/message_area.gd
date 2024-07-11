extends Area3D

@export var message: String


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.display_message(message)


func _on_body_exited(body):
	if body.is_in_group("player"):
		queue_free()
