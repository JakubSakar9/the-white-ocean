extends CanvasLayer

@export var info_message_duration: float = 4.0

@onready var fps_label: Label = %FPSLabel
@onready var body_temp_label: Label = %BodyTempLabel
@onready var info_label: Label = %InfoLabel
@onready var info_timer: Timer = %InfoTimer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	body_temp_label.text = "Body Temperature: " + "%.2f" % get_parent().body_temperature + "%"


func display_message(message: String):
	info_label.text = message
	info_label.show()
	info_timer.start(info_message_duration)


func _on_info_timer_timeout():
	info_label.hide()
