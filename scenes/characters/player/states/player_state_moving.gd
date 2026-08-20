class_name PlayerStateMoving
extends PlayerState

## Player State: Moving
##
## This handles the behaviour for the player state: State.MOVING
## It contains all processing, signals, etc required for this state
## Transitions:
## Moving > Picking Up
## Moving > Throwing
## Moving > Slashing
## Moving > Kicking
## Moving > Blocking

const DURATION_BETWEEN_FOOTSTEPS_WALK : int = 500 ## ms of wait between footsteps sfx while walking
const DURATION_BETWEEN_FOOTSTEPS_RUN : int = 300 ## ms of wait between footsteps sfx while running
const DEBUG_MODE : bool = true ## WARNING: This will enable debug mode!

var time_since_last_footstep : = Time.get_ticks_msec() ## Variable to store the time between steps

## All input code needs to stay in _process
func _process(_delta: float) -> void:
	## Setup for the equipment button (E) to pickup an object and if he can pickup an object...
	if Input.is_action_just_pressed("use") and player.can_pickup_object():		
		transition_state(Player.State.PICKING_UP)	## Emit the signal with the state to transition to
		
	## Setup for the thrown button (R) to thrown an object and if he can thrown an object...
	elif Input.is_action_just_pressed("throw") and player.equipment.has_weapon():	
		transition_state(Player.State.THROWING)	## Emit the signal with the state to transition to		
		
	## Setup for the thrown button (LMB) to slash with the melee weapon that player should have equipped...
	elif Input.is_action_just_pressed("action") and player.equipment.has_weapon():	
		transition_state(Player.State.SLASHING)	## Emit the signal with the state to transition to		
		
	## Setup for the thrown button (F) to kick
	elif Input.is_action_just_pressed("kick"):
		if DEBUG_MODE:
			print_rich("[color=yellow][b]WARNING:[/b] player_State_moving.gd DEBUG MODE is [b]ON[/b][/color]")
			player.experience.gain_experience(35)	
		transition_state(Player.State.KICKING)	## Emit the signal with the state to transition to		
	
	## Setup for the block button (RMB) to block
	elif Input.is_action_just_pressed("block") and player.equipment.has_shield():	
		transition_state(Player.State.BLOCKING)	## Emit the signal with the state to transition to	
	
	## Setup for the jump button (SPACE) to jump
	elif player.is_on_floor() and Input.is_action_just_pressed("jump"):
		AudioManager.play("jump", player.vocal_audio_stream_player) ## Play the SFX
		player.velocity.y = player.jump_force # apply a upward motion		

## All movement/animation code needs to be processed at physic_process 
func _physics_process(delta: float) -> void:
	## Process Movement
	player.process_movement(delta)
	
	## Apply animation	
	var horizontal_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
	
	## Calculate the velocity and set either the run or idle animation accordingly
	if horizontal_velocity.length_squared() > 0.1 and player.is_on_floor():
		player.animation_player.play("run")
		
		## Start the appropriate steps timer		
		var duration : int = DURATION_BETWEEN_FOOTSTEPS_WALK ## By default use the WALK steps duration
		
		if Input.is_action_pressed("run"):
			duration = DURATION_BETWEEN_FOOTSTEPS_RUN ## While running we use the run steps duration
		
		## Check the time	
		if Time.get_ticks_msec() - time_since_last_footstep > duration:
			AudioManager.play("footstep", player.footstep_audio_stream_player) ## Play the steps sound
			time_since_last_footstep = Time.get_ticks_msec()	## Reset the timer	
	else:
		player.animation_player.play("idle")	
