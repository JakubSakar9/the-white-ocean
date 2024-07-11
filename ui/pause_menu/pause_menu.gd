extends CanvasLayer

@onready var resume_label = %ResumeLabel
@onready var exit_label = %ExitLabel

var selected_idx: int = -1
var player: Node

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_idx == 0:
			hide_menu()
			print("Should hide")
		elif selected_idx == 1:
			get_tree().quit()
	

func _ready():
	player = get_tree().get_first_node_in_group("player")
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	
func hide_menu():
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	
	
func show_menu():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()


func _on_resume_label_mouse_entered():
	selected_idx = 0
	resume_label.self_modulate = Color.DARK_GRAY


func _on_resume_label_mouse_exited():
	selected_idx = -1
	resume_label.self_modulate = Color.WHITE


func _on_exit_label_mouse_entered():
	selected_idx = 1
	exit_label.self_modulate = Color.DARK_GRAY


func _on_exit_label_mouse_exited():
	selected_idx = -1
	exit_label.self_modulate = Color.WHITE
