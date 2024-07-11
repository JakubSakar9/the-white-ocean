extends CharacterBody3D

@export_category("Controls")
@export var mouse_sensitivity: float = 1.0
@export var movement_speed: float = 3.0

@onready var camera: Camera3D = $PlayerCamera
@onready var gameplay_overlay: CanvasLayer = $GameplayOverlay
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var game_over_menu: CanvasLayer = $GameOverMenu
@onready var footstep_generator = %FootstepGenerator

const JUMP_VELOCITY: float = 4.5
const CAM_CLAMP: float = PI * 0.5
const EPSILON: float = 0.0001
const DRONE_BUS: int = 1

var gravity = 9.8
var environment_node: WorldEnvironment

var mouse_diff: Vector2 = Vector2.ZERO
var was_walking: bool = false

@export_category("Body Temperature")
@export var temperature_loss: float = 1.0
var body_temperature: float = 100.0
var body_temperature_ceiling: float = 100.0

func _ready():
	environment_node = get_tree().get_first_node_in_group('environment') as WorldEnvironment
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_diff += event.relative
	#if Input.is_action_pressed("FocusVision"):
		#focusing_vision = true
	#else:
		#focusing_vision = false
	#if Input.is_action_pressed("FocusHearing"):
		#focusing_hearing = true
	#else:
		#focusing_hearing = false
	if Input.is_action_just_pressed("Pause"):
		pause_menu.show_menu()


func _process(delta):
	if body_temperature > 0.0:
		# Body temperature decreases by default
		body_temperature = max(0.0, body_temperature - temperature_loss * delta)
	else:
		game_over()
		

	if body_temperature < body_temperature_ceiling - 10.0:
		body_temperature_ceiling -= 10.0


func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir: Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveFwd", "MoveBwd")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not was_walking:
			was_walking = true
			footstep_generator.start_motion()
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		if was_walking:
			was_walking = false
			footstep_generator.end_motion()
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)
		
	#current_sensitivity = mouse_sensitivity / fv_value
	var hor_rotation: float = mouse_diff.x * delta * mouse_sensitivity
	var ver_rotation: float = mouse_diff.y * delta * mouse_sensitivity
	mouse_diff = Vector2.ZERO
	rotate_object_local(Vector3.DOWN, hor_rotation)
	camera.rotate_object_local(Vector3.LEFT, ver_rotation)
	camera.rotation.x = clamp(camera.rotation.x, -CAM_CLAMP, CAM_CLAMP)
	
	move_and_slide()


func game_over():
	game_over_menu.show_menu()
	
	
func cool_down(value: float):
	body_temperature = max(body_temperature - value, 0)
	

func warm_up(value: float):
	body_temperature = min(body_temperature + value, body_temperature_ceiling)

	
func display_message(message: String):
	gameplay_overlay.display_message(message)
