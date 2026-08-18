class_name Player
extends CharacterBody3D

## Player class and First Person Controller.
##
## This handles both the [b]Player[/b] and the [b]FPS Camera Controller[/b],
## includes anything for the player.[br]
## This has two components:[br]1- looking around[br]2- moving around.

const SPIKE_DAMAGE : int = 5				##how much damage spike cause to the player
const MAX_ANGLE_LOOK_UP := deg_to_rad(70)	## Can't go more than 70° looking up
const MAX_ANGLE_LOOK_DOWN := deg_to_rad(-70)	## Can't go more than -70° looking down
const GROUND_FRICTION : float = 15.0			## Used to slow down after a pushback

## UI STRINGS
const UI_STRING_PICKUP : String = "[E] Pick Up"
const UI_STRING_KICK_DOOR : String = "[F] Open"
const UI_STRING_KICK_ENEMY : String = "[F] Kick"

@export var acceleration : float ## Acceleration of the player movement, used to allow for friction to speed up / down rather than abrut movement. A good value is walk_speed * 10.[br]For example for a 3 walk_speed and 30 acceleration, it will take 0.1s (100 ms) to reach it
@export var jump_force : float ## The jump intensity for the player
@export var gravity : float ## The force of gravity, that applies to the player
@export var mouse_sensitivity : float ## Mouse Sensitivity: Use to determine the mouse look speed. 
@export var run_speed : float ## Speed of running movement, used for WASD + SHIFT for running. 
@export var walk_speed : float ## Speed of regular movement, used for WASD. 
@export var capture_mouse_enabled : bool = true ## If set to true, mouse will be captured so it can't go outside of the window.
@export var duration_hurt : float			## Time in seconds for the duration of the hurt state
@onready var action_audio_stream_player: AudioStreamPlayer3D = %ActionAudioStreamPlayer3D
@onready var footstep_audio_stream_player: AudioStreamPlayer3D = %FootstepAudioStreamPlayer
@onready var vocal_audio_stream_player: AudioStreamPlayer3D = %VocalAudioStreamPlayer

@onready var animation_player: AnimationPlayer = $character/AnimationPlayer ## Reference to the AnimationPlayer to handle animations
@onready var camera: Camera3D = %MainCamera ## Reference to the Camera3D node. 
@onready var select_raycast: RayCast3D = %SelectRaycast		## Reference to the RayCast used for pick up objects
@onready var kick_raycast: RayCast3D = %KickRaycast
@onready var equipment: EquipmentComponent = %EquipmentComponent 	## refenrec eto tehe quipment component
@onready var health: HealthComponent = %HealthComponent			## refenrec eto tehe health component
@onready var weapon_reach_raycast: RayCast3D = %WeaponReachRaycast ## needed to check wheter the player can hit the Enemy

enum State {MOVING, PICKING_UP, THROWING, SLASHING, KICKING, BLOCKING, HURT, DYING}

var current_pickable_focused_item : PickableItem = null	## This will hold a PickableItem that is currently pickable (in range and hit by the select_raycast)
var input_dir := Vector2.ZERO ## Store the direction of movement from player input. Represents the player hitting W-A-S-D
var pushback_force := Vector3.ZERO ## the pushback force sustained after a hit
var state : State	## State the player is in
var state_node : PlayerState ## The Node that holds the current state the player is in
var current_possible_action: String = "" ## Stores the possible action (TEXT for the ActionLabel) for the player to take which might be PICKUP something or KICK the door

func _ready() -> void:
	if capture_mouse_enabled:
		# Capture the mouse so it doesn't go outside of the window (F8 to stop debugging)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	## Register the player reference to the GameState global
	GameState.register_player(self)	
	
	## Emit the player_spawned event, used for example by the UI to refresh HP bar
	GameEvents.player_spawned.emit(self)
	
	## Register to the key_picked_up event
	GameEvents.key_picked_up.connect(on_key_picked_up)
		
	# Call the switch_state function to set the starting state
	switch_state(State.MOVING)
	
func _process(_delta: float) -> void:
	## Setup the input direction using the get_vector function that maps a Vector2 to a input: 
	## negative x motion (strafe left), positive x motion (stafe right), negative y motion (go backward), postive y motion (go forward)
	input_dir = Input.get_vector("strafe_left","strafe_right","backward","forward")	
	
func _physics_process(delta: float) -> void:
	process_gravity()	## process gravity so is_on_floor() works properly	
	process_pushback(delta) ## Apply pushback
	move_and_slide() ## Apply movemenet	
	check_for_selection() ## Check if a pickable item is being looked at (inside the select_raycast range)
	check_for_possible_action() ## Check if a new action is possible, meaning, check if the ActionPanel needs to be updated

func process_movement(delta: float, speed_multiplier: float = 1.0) -> void:
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
	
	## Add the speed_multiplier if it was passed
	target_speed *= speed_multiplier
	
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

## Handle the pushback decaying towards 0 (full stop)
func process_pushback(delta: float) -> void:
	## Move the pushbackforce to 0 (to decay it)
	pushback_force = pushback_force.move_toward(Vector3.ZERO, delta * GROUND_FRICTION)
	## Apply it to the velocity
	velocity += pushback_force

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
## Takes the new state and optionally the PlayerStateData for arguments
func switch_state(new_state: State, data: PlayerStateData = PlayerStateData.new()) -> void:
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
		State.BLOCKING: PlayerStateBlocking,
		State.HURT: PlayerStateHurt,
		State.DYING: PlayerStateDying
	}	
	## 1 - Create the proper PlayerState node
	state_node = state_map[new_state].new(self, data)
	## 1.5 - Listen to the transition_state signal and connect to this function
	state_node.transition_requested.connect(switch_state)	
	## 1.6 - Add a name to the node so it is clear in the tree
	state_node.name = "State_" + State.keys()[new_state]
	## 1.7 - Store the player state
	state = new_state	
	## 2 - Add it to the player scene	
	add_child(state_node)

func process_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity # apply gravity downwards

func check_for_possible_action() -> void:
	var new_action := ""
	
	## Check if there's something that can be picked up
	if select_raycast.is_colliding():
		new_action = UI_STRING_PICKUP
	## Check if there's instead a door ready to be kicked	
	elif kick_raycast.is_colliding():
		if kick_raycast.get_collider() is Door:
			new_action = UI_STRING_KICK_DOOR
		elif kick_raycast.get_collider() is Enemy:
			new_action = UI_STRING_KICK_ENEMY ## We might not want to show this to the player
		
	if new_action != current_possible_action:
		## The action changed (so we're not just, for example, looking at the same pickable item, but we changed our view to anotehr item or a door)
		## So we emit the event in order for the UI text to be updated
		## We only do this if it changed (to something new or to nothing, to make it disappear), to avoid a unneded "refresh"
		GameEvents.possible_action_changed.emit(new_action)	
	
	## Set the current action accordingly	
	current_possible_action = new_action	

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
func try_receive_hit(source_enemy: Enemy, damage: int) -> void:
	## First we check if the player can get hit
	if state_node.can_get_hurt():
		## Calc the hit direction from the enemy to the player
		var hit_direction : Vector3 = source_enemy.global_position.direction_to(global_position)
		
		var data: PlayerStateData = PlayerStateData.new().set_damage(damage).set_impact_direction(hit_direction)
		
		AudioManager.play("slash-hit", action_audio_stream_player) ## PLay the SFX
		
		switch_state(State.HURT, data) ## go to to hurt state, passing damage and hitdirection		
	elif state == State.BLOCKING:
		## Player cannot be hurt, and they are blocking
		
		## Play SFX
		AudioManager.play("block", action_audio_stream_player)
		
		## Damage the player shield itself if the player was blocking. Damange is the damage of the weapon (so the shield gets the dmaage intended to player)
		equipment.apply_shield_damage(damage)
		
		## Let's stun the enemy
		source_enemy.try_stun()
		
## To handle receiving damage from spikes trap
func take_spike_damage(spikes_trap: SpikesTrap) -> void:
	## Calc the hit direction from the enemy to the player
	var hit_direction : Vector3 = spikes_trap.global_position.direction_to(global_position)
	
	var data: PlayerStateData = PlayerStateData.new().set_damage(SPIKE_DAMAGE).set_impact_direction(hit_direction)
	switch_state(State.HURT, data) ## go to to hurt state, passing damage and hitdirection		

## This returns true if there is an pickable item being looked at right now		
func can_pickup_object() -> bool:			
	return current_pickable_focused_item != null
	
## Handles taking acid damage when in contact with the Acid Trap	
func take_acid_damage() -> void: 
	if state_node.can_die():
		switch_state(State.DYING)

## THe player just picked up a key
func on_key_picked_up(_color: Door.KeyColor) -> void:
	AudioManager.play("key-pickup", vocal_audio_stream_player) ## Play the SFX
