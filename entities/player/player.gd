extends CharacterBody3D

@export_category("Controls")
@export var joy_sensitivity: float = 2.0
@export var movement_speed: float = 3.0
@export var jump_speed: float = 3.0

@onready var camera: Camera3D = %PlayerCamera
@onready var skeleton: Skeleton3D = %Skeleton3D
@onready var player_animator = %PlayerAnimator
@onready var gameplay_overlay: CanvasLayer = $GameplayOverlay
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var game_over_menu: CanvasLayer = $GameOverMenu
@onready var footstep_generator = %FootstepGenerator
@onready var snow_particle_generator = $SnowParticleGenerator
@onready var interaction_raycast: RayCast3D = %InteractionRaycast
@onready var stable_pivot: Node3D = %StablePivot
@onready var bobbing_pivot: Node3D = %BobbingPivot
@onready var stable_neck: Node3D = %StableNeck

const HEAD_CLAMP: float = 0.6
const EPS: float = 0.0001

@export_category("Misc")
@export_range(1.0, 100.0) var wind_resistance: float = 5.0
@export var sonar_fade_speed: float = 2.0

# Private variables
var _gravity: float = 9.8
var _environment_node: WorldEnvironment
var _wind_node: Node
var _head_bone_idx: int
var _mouse_diff: Vector2 = Vector2.ZERO
var _rot_joy_diff: Vector2 = Vector2.ZERO
var _sonar_t: float = 1.0
var _was_walking: bool = false
var _object_focused: bool = false
var _dead: bool = false

@export var temperature_loss: float = 1.5
@export var cold_temperature_gain: float = 0.5
@export var warm_temperature_gain: float = 2.5

var body_temperature: float = 100.0
var body_temperature_ceiling: float = 100.0
var inside: bool = false
var fireplace_on: bool = false

func _ready():
	if not SaveManager.player_loaded:
		position = SaveManager.player_position
		body_temperature = SaveManager.player_bt
		body_temperature_ceiling = SaveManager.player_bt_ceiling
		SaveManager.player_loaded = true
	
	_environment_node = get_tree().get_first_node_in_group('environment') as WorldEnvironment
	_wind_node = get_tree().get_first_node_in_group('wind')
	if _wind_node == null:
		inside = true
	else:
		snow_particle_generator.emitting = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_head_bone_idx = skeleton.find_bone("mixamorig_Head")
	player_animator.play("Idle")
	SceneSwitcher.on_player_registered.emit()

func _unhandled_input(event: InputEvent) -> void:
	if _dead:
		return
	# Handle mouse rotation
	if event is InputEventMouseMotion:
		_mouse_diff += event.relative
	# Handle joystick rotation
	_rot_joy_diff = Input.get_vector("RotateLeft", "RotateRight", "RotateUp", "RotateDown")
	if Input.is_action_just_pressed("Pause"):
		pause_menu.show_menu()
	if Input.is_action_just_released("Interact") and interaction_raycast.is_colliding():
		handle_interaction()


func _process(delta) -> void:
	if _dead:
		return
	if body_temperature > 0.0:
		# Body temperature decreases by default
		if not inside:
			var actual_tl: float = temperature_loss
			actual_tl *= (1.0 - _wind_node.reduction)
			body_temperature = max(-EPS, body_temperature - actual_tl * delta)
		elif fireplace_on:
			body_temperature = min(body_temperature_ceiling, \
			body_temperature + warm_temperature_gain * delta)
		else:
			body_temperature = min(body_temperature_ceiling, \
			body_temperature + cold_temperature_gain * delta)
	else:
		game_over()
		

	if body_temperature < body_temperature_ceiling - 10.0 and not fireplace_on:
		body_temperature_ceiling -= 10.0

	gameplay_overlay.update_body_temp(body_temperature)

	# Sonar controls
	if Input.is_action_pressed("UseSonar"):
		sonar_fade_in(delta)
	else:
		sonar_fade_out(delta)
	var sonar_bus: int = AudioServer.get_bus_index("Sonar")
	var sonar_attenuation: float = -80 * (1.0 - _sonar_t) ** 2
	AudioServer.set_bus_volume_db(sonar_bus, sonar_attenuation)

func _physics_process(delta: float) -> void:
	if _dead:
		return
	
	# Add the _gravity.
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_speed

	# Handle movement
	var input_dir: Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveFwd", "MoveBwd")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not _was_walking:
			_was_walking = true
			player_animator.play("Walking")
			footstep_generator.start_motion(inside)
				
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
		if not inside:
			var wind_drag: Vector3 = _wind_node.wind_vector / wind_resistance
			velocity += wind_drag
	else:
		if _was_walking:
			_was_walking = false
			footstep_generator.end_motion()
			player_animator.play("Idle")
			#player_animator.stop()
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)
		
	# Handle camera rotation
	var mouse_sensitivity = GlobalSettings.mouse_sensitivity
	var rot_diff: Vector2 = _mouse_diff * mouse_sensitivity + _rot_joy_diff * joy_sensitivity
	var hor_rotation: float = rot_diff.x * delta
	var ver_rotation: float = rot_diff.y * delta
	_mouse_diff = Vector2.ZERO
	rotate_object_local(Vector3.DOWN, hor_rotation)
	var head_rotation: Quaternion = skeleton.get_bone_pose_rotation(_head_bone_idx)
	head_rotation.x += ver_rotation
	head_rotation.x = clamp(head_rotation.x, -HEAD_CLAMP, HEAD_CLAMP)
	head_rotation = head_rotation.normalized()
	var stable_neck_rotation = head_rotation.get_euler()
	stable_neck_rotation.x *= -1
	stable_neck.rotation = stable_neck_rotation
	skeleton.set_bone_pose_rotation(_head_bone_idx, head_rotation)
	
	# Handle interaction raycast
	if interaction_raycast.is_colliding() and not _object_focused:
		_object_focused = true
		var focused_object: Area3D = interaction_raycast.get_collider()
		var message: String = focused_object.message
		gameplay_overlay.display_message(message)
	elif not interaction_raycast.is_colliding() and _object_focused:
		_object_focused = false
		gameplay_overlay.end_message()
	
	var stable_transform: Transform3D = stable_pivot.global_transform
	var bobbing_transform: Transform3D = bobbing_pivot.global_transform
	var bf: float = GlobalSettings.bobbing_factor
	var camera_transform: Transform3D = stable_transform.interpolate_with(bobbing_transform, bf)
	camera.global_transform = camera_transform
	
	move_and_slide()


func handle_interaction():
	var colliding_area: Area3D = interaction_raycast.get_collider()
	if colliding_area.has_method("interact"):
		colliding_area.interact(self)
		

func light_fireplace() -> void:
	body_temperature_ceiling = 100.0
	fireplace_on = true


func game_over():
	game_over_menu.show_menu()
	_dead = true
	
	
func cool_down(value: float):
	body_temperature = max(body_temperature - value, 0)
	

func warm_up(value: float):
	body_temperature = min(body_temperature + value, body_temperature_ceiling)

	
func display_message(message: String):
	gameplay_overlay.display_message(message)
	

func end_message():
	gameplay_overlay.end_message()



func sonar_fade_in(delta: float):
	_sonar_t = min(1.0, _sonar_t + delta * sonar_fade_speed)


func sonar_fade_out(delta: float):
	_sonar_t = max(0.0, _sonar_t - delta * sonar_fade_speed)
