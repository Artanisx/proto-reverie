class_name PlayerStateMoving
extends PlayerState

## Player State: Moving
##
## This handles the behaviour for the player state: State.MOVING
## It contains all processing, signals, etc required for this state
## Transitions:
## Moving > Picking Up

## All input code needs to stay in _process
func _process(delta: float) -> void:
	## Setup for the equipment button (E) to pickup an object and if he can pickup an object...
	if Input.is_action_just_pressed("use") and player.can_pickup_object():
		transition_state(Player.State.PICKING_UP)	## Emit the signal with the state to transition to

## All movement/animation code needs to be processed at physic_process 
func _physics_process(delta: float) -> void:
	## Process Movement
	player.process_movement(delta)
	
	## Apply animation	
	var horizontal_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
	
	## Calculate the velocity and set either the run or idle animation accordingly
	if horizontal_velocity.length_squared() > 0.1 and player.is_on_floor():
		player.animation_player.play("run")
	else:
		player.animation_player.play("idle")
