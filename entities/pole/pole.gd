extends StaticBody3D

@onready var pole_audio = %PoleAudio
@onready var warming_area = %WarmingArea
@onready var beep_timer = %BeepTimer

@export var warming_range: float = 20.0
@export var warming_factor: float = 5.0
@export var min_beep_f: float = 0.5
@export var max_beep_f: float = 20.0
@export var beep_increase_factor: float = 7.0
@export var volume_gain_db: float = 0.0

var player: Node
var player_nearby: bool = false
var beep_on: bool = true

func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	pole_audio.pitch_scale = 0.5 + rng.randf()
	pole_audio.volume_db = volume_gain_db - 15.0
	
	warming_area.scale = Vector3(warming_range, warming_range, warming_range)
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var player_vec: Vector3 = player.global_position - global_position
	var player_dist: float = player_vec.length()
	if player_dist < warming_range:
		player_nearby = true
	

func _process(delta) -> void:
	if player_nearby:
		player.warm_up(delta * warming_factor)
		
	# Update beep frequency based on player distance
	var player_vec: Vector3 = player.global_position - global_position
	var player_dist: float = player_vec.length()
	var f_factor: float = 1 + player_dist / beep_increase_factor
	f_factor *= 1 + player_dist / beep_increase_factor
	var beep_f: float = min_beep_f + (max_beep_f - min_beep_f) / f_factor
	beep_timer.wait_time = 1 / beep_f

func _on_warming_area_body_entered(body):
	if body.is_in_group("player"):
		player_nearby = true


func _on_warming_area_body_exited(body):
	if body.is_in_group("player"):
		player_nearby = false


func _on_beep_timer_timeout():
	if beep_on:
		beep_on = false
		pole_audio.playing = false
	else:
		beep_on = true
		pole_audio.playing = true	
