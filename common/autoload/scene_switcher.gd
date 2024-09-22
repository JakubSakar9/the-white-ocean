extends Node


signal on_player_registered

const MENU_PATH: String = "res://ui/main_menu/main_menu.tscn"

func menu_to_world():
	# Fade to black
	var scene_path = SaveManager.last_scene
	TransitionScreen.fade_in()
	await TransitionScreen.on_fade_finished
	
	get_tree().change_scene_to_file(scene_path)
	await on_player_registered
	
	TransitionScreen.fade_out()
	

func splash_transition():
	world_to_menu()
	

func world_to_menu():
	# Fade to black
	TransitionScreen.fade_in()
	await TransitionScreen.on_fade_finished
	
	get_tree().change_scene_to_file(MENU_PATH)
	
	TransitionScreen.fade_out()
	

func world_to_world(scene: String, from_building: bool):
	SaveManager.fireplace_on = false
	
	# Fade to black
	TransitionScreen.fade_in()
	await TransitionScreen.on_fade_finished
	
	var player_node: Node = get_tree().get_first_node_in_group("player")
	SaveManager.player_bt = player_node.body_temperature
	
	if from_building:
		SaveManager.from_building()
		toggle_wind_muffle(false)
	else:
		SaveManager.to_building(player_node.position, scene)
		toggle_wind_muffle(true)
		
	get_tree().change_scene_to_file(scene)
	await on_player_registered
	player_node = get_tree().get_first_node_in_group("player")
	
	player_node.body_temperature = SaveManager.player_bt
	if from_building:
		player_node.position = SaveManager.player_position
	
	TransitionScreen.fade_out()
	

func respawn_transition():
	SaveManager.fireplace_on = true
	TransitionScreen.fade_in()
	await TransitionScreen.on_fade_finished
	
	# Scene remains the same, player moves back to the start
	if SaveManager.last_scene_rs != SaveManager.last_scene:
		get_tree().change_scene_to_file(SaveManager.last_scene_rs)
		await on_player_registered
		var player_node = get_tree().get_first_node_in_group("player")
		player_node.position = SaveManager.player_position_rs
		toggle_wind_muffle(true)
	else:
		get_tree().reload_current_scene()
	TransitionScreen.fade_out()
	

func toggle_wind_muffle(val: bool):
	var wind_bus: int = AudioServer.get_bus_index("Wind")
	var wind_lpf: AudioEffectLowPassFilter = AudioServer.get_bus_effect(wind_bus, 0)
	if val:
		wind_lpf.cutoff_hz = 400.0
		wind_lpf.resonance = 0.9
	else:
		wind_lpf.cutoff_hz = 600.0
		wind_lpf.resonance = 0.5
