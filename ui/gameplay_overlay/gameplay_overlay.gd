extends CanvasLayer

@onready var fps_label: Label = %FPSLabel
@onready var body_temp_label: Label = %BodyTempLabel
@onready var info_label: Label = %InfoLabel
# @onready var info_label_animation = %InfoLabelAnimation
@onready var body_temp_bar = %BodyTempBar

@export var fade_time: float = 0.35

var _fade_tween: Tween = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	body_temp_label.text = "Body Temperature: " + "%.2f" % get_parent().body_temperature + "%"


func display_message(message: String) -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = get_tree().create_tween()	
	if info_label.visible:
		_fade_tween.tween_property(info_label, "modulate:a", 0.0, fade_time)
		_fade_tween.step_finished.connect(update_label_message.bind(message))
	else:
		info_label.visible = true
		info_label.text = message
	_fade_tween.tween_property(info_label, "modulate:a", 1.0, fade_time)


func end_message() -> void:
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = get_tree().create_tween()	
	_fade_tween.tween_property(info_label, "modulate:a", 0.0, fade_time)
	_fade_tween.step_finished.connect(set.bind("visible", false))


func update_body_temp(val: float) -> void:
	body_temp_bar.update_val(val)


func update_label_message(_idx: int, message: String) -> void:
	info_label.text = message


func _on_info_label_animation_animation_finished(anim_name):
	if anim_name == "fade_out":
		info_label.hide()
