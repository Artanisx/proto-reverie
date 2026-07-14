class_name Player
extends CharacterBody3D

## Player class and First Person Controller.
##
## This handles both the [b]Player[/b] and the [b]FPS Camera Controller[/b],
## includes anything for the player.[br]
## This has two components:[br]1- looking around[br]2- moving around.

const MAX_ANGLE_LOOK_UP := deg_to_rad(70)	## Can't go more than 70° looking up
const MAX_ANGLE_LOOK_DOWN := deg_to_rad(-70)	## Can't go more than -70° looking down

@export var acceleration : float ## Acceleration of the player movement, used to allow for friction to speed up / down rather than abrut movement. A good value is walk_speed * 10.[br]For example for a 3 walk_speed and 30 acceleration, it will take 0.1s (100 ms) to reach it
@export var jump_force : float ## The jump intensity for the player
@export var gravity : float ## The force of gravity, that applies to the player
@export var mouse_sensitivity : float ## Mouse Sensitivity: Use to determine the mouse look speed. 
@export var run_speed : float ## Speed of running movement, used for WASD + SHIFT for running. 
@export var walk_speed : float ## Speed of regular movement, used for WASD. 

@onready var camera: Camera3D = %Camera3D ## Reference to the Camera3D node. 

var input_dir := Vector2.ZERO ## Store the direction of movement from player input. Represents the player hitting W-A-S-D

func _ready() -> void:
	# Capture the mouse so it doesn't go outside of the window (F8 to stop debugging)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(_delta: float) -> void:
	## Setup the input direction using the get_vector function that maps a Vector2 to a input: 
	## negative x motion (strafe left), positive x motion (stafe right), negative y motion (go backward), postive y motion (go forward)
	input_dir = Input.get_vector("strafe_left","strafe_right","backward","forward")
	
func _physics_process(delta: float) -> void:	
	check_jump_input()	## handles player jump
	process_gravity()	## process gravity so is_on_floor() works properly
	
	## HANDLE MOVEMENT (moving around)
	## Move the player using its velocity vector
	## We call this in _physics_process because we need to make sure all collision calculations (physics) are done before
	## Otherwise we might end up in a wall.
	
	## Translate this input direction to 3D vector, considering that moving forward goes in the negative Z axis (not Y)
	## x matches x of the input dir
	## y = 0, as we don't want to move up/down
	## z is actually y of the input dir, but reversed because forward is positive Z in 3D space wherease it's negative Y in 2D space
	var input_3d_space := Vector3(input_dir.x, 0, -input_dir.y)
		
	## First, check if we are using either walk_speed or run speed depending if the player is holding the run key	
	var target_speed : float
	if Input.is_action_pressed("run"):
		target_speed = run_speed
	else:
		target_speed = walk_speed
	
	## Now that we have the direction vector we can apply it to the velocity
	## transform.basis is basically the position of the player, it's local origin, that we need to multiply by the direction vector to get our velocity
	## multiplied by the target_speed	
	var desired_velocity := transform.basis * input_3d_space * target_speed
	
	
	## If the player is not pressing any WASD key, we want to decelerate towards zero
	if input_3d_space == Vector3.ZERO:
		## We update X and Z only, not Y or we mess up with jump
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)
	else:
		## The player is moving (pressing a WASD key), we want to accelerate towards the calculated desired velocity
		## So, apply acceleration to make sure we gradually reach it rather tha abrutly
		## Again, we only want to update X and Z, not Y that is the up/down vector
		velocity.x = move_toward(velocity.x, desired_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, desired_velocity.z, acceleration * delta)
	
	## Apply movemenet
	move_and_slide()

func _input(event: InputEvent) -> void:
	## HANDLE MOUSE LOOK (looking around)
	if event is InputEventMouseMotion:
		# The event.relative Vector2 contains the X and Y position of the mouse relative to the current
		# mouse position. This means the current movement is stored. 
		# You can visualize it using this with the below print
		# print("x: %f, y: %f" % [event.relative.x, event.relative.y])
		
		## HORIZONTAL
		# When the player moves the mouse to the left (X axis), we need to rotate the player towards positive Y axis
		# as in order to look right, we rotate on the Y axis on the positive
		# As such we rotate Y of the -X relative mouse because the movement must be inverted to obtain this result.
		# We multiply it by a mouse_sensitivity value in order to have a movement that is paced and not jittery.	
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		## VERTICAL
		# When looking vertically, we don't want to rotate the entire player, but just the head. Rather, just the camera.
		# We need to rotate the camera on its X axies this time.
		# Moving he mouse UP (Y movement will be negative) the X axis rotation of the camera will need to be positive to look up.
		# As such we rotate X of the -Y relative mouse because the movement will need again to be inverted (move mouse up, look camera up).
		# We need to rotate on the camera, not the player, though.
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# Clamp camera X rotation (up/down) to restrict the angles
		camera.rotation.x = clampf(camera.rotation.x, MAX_ANGLE_LOOK_DOWN, MAX_ANGLE_LOOK_UP)	

func check_jump_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force # apply a upward motion		

func process_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity # apply gravity downwards
