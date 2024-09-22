extends Area3D

@export var message: String = "Press E to save the game"

@onready var fire_light: OmniLight3D = %FireLight
@onready var fire: GPUParticles3D = %Fire
@onready var fire_sound: AudioStreamPlayer3D = %FireSound

var lit: bool = false

const LIGHT_TIME: float = 0.5

func _ready() -> void:
	if SaveManager.fireplace_on:
		var player = get_tree().get_first_node_in_group("player")
		light(player)

func interact(player: CharacterBody3D):
	if lit:
		return
	else:
		light(player)
	
func light(player: CharacterBody3D):
	player.light_fireplace()
	SaveManager.save_respawn(player)
	var light_tween: Tween = get_tree().create_tween()
	light_tween.set_parallel(true)
	light_tween.tween_property(fire_light, "light_energy", 1.0, LIGHT_TIME)
	light_tween.tween_property(fire, "amount_ratio", 1.0, LIGHT_TIME)
	fire_sound.play()
	message = ""
	lit = true
