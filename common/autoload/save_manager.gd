extends Node

# NOTE: Autosaving is not implemented yet
# LV - Loaded value, only used after loading the game
# TS - Triggered save, updated only during a specific event

# Initial state
var player_position_init: Vector3 = Vector3(0.268, 0, -0.424)
var return_position_init: Vector3 = Vector3(46.873, 2.062, -151.061)
var player_bt_init: float = 100.0
var player_bt_ceiling_init: float = 100.0
var last_scene_init: String = "res://levels/shelter/shelter.tscn"
var return_scene_init: String = "res://levels/test_level3/test_level3.tscn"
var fireplace_on_init: bool = true

# Quicksave state
var player_position: Vector3 # LV
var return_position: Vector3 # TS - Entering a building
var player_bt: float # LV
var player_bt_ceiling: float # LV
var last_scene: String # TS - Scene switch
var return_scene: String # TS - Entering a building
var fireplace_on: bool # LV

# Respawn state
var player_position_rs: Vector3 = Vector3.ZERO # TS - Fireplace / Init
var last_scene_rs = "res://levels/test_level3/test_level3.tscn" # TS - Fireplace / Init
var return_position_rs: Vector3 = Vector3.ZERO # TS - Fireplace
var return_scene_rs: String = "" # TS - Fireplace

# Signifies if all player related values have been loaded after starting the game
var player_loaded: bool = false

const QS_PATH: String = "user://quicksave.tres"
const GAME_VERSION = "0.4.1"

func reset() -> void:
	player_position = player_position_init
	return_position = return_position_init
	player_bt = player_bt_init
	player_bt_ceiling = player_bt_ceiling_init
	last_scene = last_scene_init
	return_scene = return_scene_init
	fireplace_on = fireplace_on_init


# Handles quicksave value reassingnment when player enters a building
func to_building(player_pos: Vector3, target_scene: String) -> void:
	return_position = player_pos
	return_scene = last_scene
	last_scene = target_scene
	

# Handles quicksave value reassignment when player leaves a building
func from_building():
	last_scene = return_scene
	player_position = return_position
	

# Saves game data for a respawn
func save_respawn(player: CharacterBody3D):
	player_position_rs = player.position
	last_scene_rs = last_scene
	return_position_rs = return_position
	return_scene_rs = return_scene


# Saves game data to a file
func save(player: CharacterBody3D) -> void:
	var save_data: SaveData = SaveData.new()
	
	save_data.fireplace_on = player.fireplace_on
	save_data.player_position = player.position
	save_data.return_position = return_position
	save_data.player_bt = player.body_temperature
	save_data.player_bt_ceiling = player.body_temperature_ceiling
	save_data.last_scene = last_scene
	save_data.return_scene = return_scene
	save_data.version = GAME_VERSION
	
	ResourceSaver.save(save_data, QS_PATH)

# Loads game data from a file	
func load() -> void:
	var save_data: SaveData = ResourceLoader.load(QS_PATH)
	player_position = save_data.player_position
	return_position = save_data.return_position
	player_bt = save_data.player_bt
	player_bt_ceiling = save_data.player_bt_ceiling
	last_scene = save_data.last_scene
	return_scene = save_data.return_scene
	fireplace_on = save_data.fireplace_on


func check_save_version() -> bool:
	var save_data: SaveData = ResourceLoader.load(QS_PATH)
	return save_data.version == GAME_VERSION


func qs_valid() -> bool:
	return ResourceLoader.exists(QS_PATH)
