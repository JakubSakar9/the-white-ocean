extends Area3D

@export var message: String = "Press E to exit"

func interact(_player: CharacterBody3D):
	var target_scene: String = SaveManager.return_scene
	SceneSwitcher.world_to_world(target_scene, true)
