extends Control

@export var initial_scene: PackedScene

@onready var splash_screen_container = %SplashScreenContainer

var splash_screens: Array[SplashScreen] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(initial_scene)
	
	for splash_screen in splash_screen_container.get_children():
		splash_screen.hide()
		splash_screens.push_back(splash_screen)
		
	start_splash_screen()


func start_splash_screen() -> void:
	if splash_screens.size() == 0:
		get_tree().change_scene_to_packed(initial_scene)
	else:
		var splash_screen: SplashScreen = splash_screens.pop_front()
		splash_screen.start()
		splash_screen.connect("finished", start_splash_screen)
