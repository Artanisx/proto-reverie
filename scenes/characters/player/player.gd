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
@export var capture_mouse_enabled : bool = true ## If set to true, mouse will be captured so it can't go outside of the window.

@onready var animation_player: AnimationPlayer = $character/AnimationPlayer ## Reference to the AnimationPlayer to handle animations
@onready var camera: Camera3D = %MainCamera ## Reference to the Camera3D node. 
@onready var select_raycast: RayCast3D = %SelectRaycast		## Reference to the RayCast used for pick up objects
@onready var kick_raycast: RayCast3D = %KickRaycast
@onready var equipment: EquipmentComponent = %EquipmentComponent 	## refenrec eto tehe quipment component
@onready var health: HealthComponent = %HealthComponent			## refenrec eto tehe health component
@onready var weapon_reach_raycast: RayCast3D = %WeaponReachRaycast ## needed to check wheter the player can hit the Enemy

enum State {MOVING, PICKING_UP, THROWING, SLASHING, KICKING, BLOCKING}

var current_pickable_focused_item : PickableItem = null	## This will hold a PickableItem that is currently pickable (in range and hit by the select_raycast)
var input_dir := Vector2.ZERO ## Store the direction of movement from player input. Represents the player hitting W-A-S-D
var state : State	## State the player is in
var state_node : PlayerState ## The Node that holds the current state the player is in

func _ready() -> void:
	if capture_mouse_enabled:
		# Capture the mouse so it doesn't go outside of the window (F8 to stop debugging)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	## Register the player reference to the GameState global
	GameState.register_player(self)	
		
	# Call the switch_state function to set the starting state
	switch_state(State.MOVING)
	
func _process(_delta: float) -> void:
	## Setup the input direction using the get_vector function that maps a Vector2 to a input: 
	## negative x motion (strafe left), positive x motion (stafe right), negative y motion (go backward), postive y motion (go forward)
	input_dir = Input.get_vector("strafe_left","strafe_right","backward","forward")	
	
func _physics_process(_delta: float) -> void:	
	check_jump_input()	## handles player jump
	process_gravity()	## process gravity so is_on_floor() works properly	
	move_and_slide() ## Apply movemenet			
	check_for_selection() ## Check if a pickable item is being looked at (inside the select_raycast range)

func process_movement(delta: float) -> void:
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

## Switch to the passed State
## The function will add a Node that will contain the behaviour for the passed state
func switch_state(new_state: State) -> void:
	## INIT: Remove the previous PlayerState node if it exists
	if state_node != null:
		state_node.queue_free()
	## 0 -- Create a dictionary containing all the states and related PlayerState classess
	var state_map := {
		State.MOVING: PlayerStateMoving,
		State.PICKING_UP: PlayerStatePickingUp,
		State.THROWING: PlayerStateThrowing,
		State.SLASHING: PlayerStateSlashing,
		State.KICKING: PlayerStateKicking,
		State.BLOCKING: PlayerStateBlocking
	}	
	## 1 - Create the proper PlayerState node
	state_node = state_map[new_state].new(self)
	## 1.5 - Listen to the transition_state signal and connect to this function
	state_node.transition_requested.connect(switch_state)	
	## 1.6 - Add a name to the node so it is clear in the tree
	state_node.name = "State_" + State.keys()[new_state]
	## 1.7 - Store the player state
	state = new_state	
	## 2 - Add it to the player scene	
	add_child(state_node)

func check_jump_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force # apply a upward motion		

func process_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity # apply gravity downwards

func check_for_selection() -> void:
	## First, we check if the select_raycast is looking at anything
	var target_node: Node = null
	
	## Check if the select_raycast is colliding with something
	## Currently selet_raycast is set to collide only with PICKABLE ITEMS in its collision mask
	## So the "is_colliding" will return true only if it's colliding with a pickable item
	if select_raycast.is_colliding():
		## Save the collider of the collided item!
		var collider := select_raycast.get_collider()
		
		## Let's make sure this is indeed a Pickable Item
		if collider is PickableItem:
			target_node = collider	## Save this as our target node
	
	## Now we check to se if what the player is currently looking at is different from what he was looking at a moment ago
	if target_node != current_pickable_focused_item:
		if current_pickable_focused_item:
			## Player was looking at a different object earlier
			current_pickable_focused_item.unhighlight()	## We must deselect it, so we unhighlight the previous object
		
		current_pickable_focused_item = target_node	## We set it the current focused item to the new item we're looking at
		
		if current_pickable_focused_item is PickableItem:
			current_pickable_focused_item.highlight()	## Let's highlight it now

## To handle receiving a hit for the player
func try_receive_hit(source_enemy: Enemy, _damage: int) -> void:
	## First we check if the player can get hit
	if state_node.can_get_hurt():
		## We dont' have a hurt state yet, so let's just display some vfx for now
		GameEvents.player_hurt.emit(self)
	elif state == State.BLOCKING:
		## Player cannot be hurt, and they are blocking
		## Let's stun the enemy
		source_enemy.try_stun()

## This returns true if there is an pickable item being looked at right now		
func can_pickup_object() -> bool:			
	return current_pickable_focused_item != null
	
## Handles taking acid damage when in contact with the Acid Trap	
func take_acid_damage() -> void: 
	print("ouch! player is in the acid trap!")
