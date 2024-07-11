class_name SplashScreen extends Control

@export var splash_time: float = 2
@export var fade_in_time: float = 0.5
@export var fade_out_time: float = 0.5

signal finished()


func start() -> void:
	modulate.a = 0
	show()
	var tween: Tween = create_tween()
	tween.connect("finished", finish)
	tween.tween_property(self, "modulate:a", 1, fade_in_time)
	tween.tween_interval(splash_time)
	tween.tween_property(self, "modulate:a", 0, fade_out_time)
	

func finish() -> void:
	emit_signal("finished")
	queue_free()
