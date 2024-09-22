extends CanvasLayer

var go_selected: bool = false
var player: Node
	

func _ready():
	player = get_tree().get_first_node_in_group("player")
	#process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	
func show_menu():
	#get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()


func _on_retry_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	SceneSwitcher.respawn_transition()
