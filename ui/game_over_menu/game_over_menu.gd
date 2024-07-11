extends CanvasLayer

@onready var retry_label = %RetryLabel

var go_selected: bool = false
var player: Node

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if go_selected:
			hide_menu()
			get_tree().reload_current_scene()
	

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


func _on_retry_label_mouse_entered():
	go_selected = true
	retry_label.self_modulate = Color.DARK_GRAY


func _on_retry_label_mouse_exited():
	go_selected = false
	retry_label.self_modulate = Color.WHITE
