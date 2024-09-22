extends Area3D

@export_file("*.tscn") var shelter_scene: String
@export var message: String = "Press E to enter"
	
func interact(_player: CharacterBody3D) -> void:
	SceneSwitcher.world_to_world(shelter_scene, false)
