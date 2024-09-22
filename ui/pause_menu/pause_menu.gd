extends CanvasLayer

@onready var menu_items_container = %MenuItemsContainer

var selected_idx: int = 0
var selected_label: Label
var hovering: bool = false
var player: Node

const N_ITEMS: int = 2

func _input(event):
	var confirmed = false
	# Key and button handling
	if event is InputEventJoypadButton or event is InputEventKey:
		if event.is_action_released("UIConfirm"):
			confirmed = true
		if event.is_action_released("UIUp"):
			switch_menu_item((selected_idx - 1) % N_ITEMS)
		if event.is_action_released("UIDown"):
			switch_menu_item((selected_idx + 1) % N_ITEMS)
	
	# Mouse handling
	var mb_confirmed = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	mb_confirmed = mb_confirmed and hovering
	confirmed = confirmed or mb_confirmed
	
	if confirmed:
		if selected_idx == 0:
			hide_menu()
		elif selected_idx == 1:
			get_tree().paused = false
			SaveManager.save(get_parent())
			SceneSwitcher.world_to_menu()
	

func _ready():
	selected_label = menu_items_container.get_children()[0]
	switch_menu_item(0)
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
	hovering = true
	selected_idx = 0
	switch_menu_item(0)


func _on_resume_label_mouse_exited():
	hovering = false


func _on_exit_label_mouse_entered():
	hovering = true
	switch_menu_item(1)


func _on_exit_label_mouse_exited():
	hovering = false


func switch_menu_item(idx: int):
	selected_idx = idx
	selected_label.self_modulate = Color.DARK_GRAY
	selected_label = menu_items_container.get_children()[2 * idx]
	selected_label.self_modulate = Color.WHITE
