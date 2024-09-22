extends Node

@export var speed: float = 1.0
@export var wind_lowpass_min: float = 400.0
@export var wind_lowpass_max: float = 3000.0

@onready var wind_player = %WindPlayer

var direction: Vector2
var wind_vector: Vector3
var reduction: float = 0.0

var snow_generator: GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	direction = Vector2.LEFT
	snow_generator = get_tree().get_first_node_in_group("snow_generator")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	wind_player.volume_db = 80.0 / sqrt(1.0 + reduction) - 80.0
	# Apply low pass filter to wind sound
	var wind_bus: int = AudioServer.get_bus_index("Wind")
	var lowpass: AudioEffectLowPassFilter = AudioServer.get_bus_effect(wind_bus, 0)
	lowpass.cutoff_hz = wind_lowpass_min + (wind_lowpass_max - wind_lowpass_min) / sqrt(1.0 + reduction)

	snow_generator.change_wind(direction, speed / (1.0 + reduction))
	wind_vector = Vector3(direction.x, 0, direction.y).normalized() * speed / (1.0 + reduction)
