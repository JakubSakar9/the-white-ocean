extends CanvasLayer

@onready var color_rect: ColorRect = %ColorRect
@onready var animation_player: AnimationPlayer = %AnimationPlayer

signal on_fade_finished

var _master_amp: AudioEffectAmplify
var _fade_length: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	layer = 4
	color_rect.visible = false
	var index: int = AudioServer.get_bus_index("Master")
	_master_amp = AudioServer.get_bus_effect(index, 0)
	_fade_length = animation_player.get_animation("fade_in").length
	color_rect.color = Color(0, 0, 0 ,0)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in" or anim_name == "white_fade_in":
		on_fade_finished.emit()
	else:
		color_rect.visible = false
		

func fade_in():
	color_rect.visible = true
	animation_player.play("fade_in")
	var tween = get_tree().create_tween()
	tween.tween_property(_master_amp, "volume_db", -80.0, _fade_length)
	
	
func fade_out():
	animation_player.play("fade_out")
	var tween = get_tree().create_tween()
	tween.tween_property(_master_amp, "volume_db", 0.0, _fade_length)
	
func white_fade_in():
	color_rect.visible = true
	animation_player.play("white_fade_in")
	
func white_fade_out():
	animation_player.play("fade_out")
