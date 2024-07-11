extends Control

#@export_file("*.tscn") var scene_path: String
@export var initial_scene: PackedScene


@onready var play_label: Label = %PlayLabel
@onready var exit_label: Label = %ExitLabel

var selected_idx: int = -1


#func _ready():
	#initial_scene = ResourceLoader.load(scene_path) as PackedScene

	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_idx == 0:
			get_tree().change_scene_to_packed(initial_scene)
		elif selected_idx == 1:
			get_tree().quit()


func _on_play_label_mouse_entered():
	selected_idx = 0
	play_label.self_modulate = Color.DARK_GRAY


func _on_play_label_mouse_exited():
	selected_idx = -1
	play_label.self_modulate = Color.WHITE


func _on_exit_label_mouse_entered():
	selected_idx = 1
	exit_label.self_modulate = Color.DARK_GRAY


func _on_exit_label_mouse_exited():
	selected_idx = -1
	exit_label.self_modulate = Color.WHITE
