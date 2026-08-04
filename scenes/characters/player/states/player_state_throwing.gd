class_name PlayerStateThrowing
extends PlayerState

## Player State: Throwing
##
## This handles the behaviour for the player state: State.THROWING
## It contains all processing, signals, etc required for this state
## Transitions:
## Throwing > Moving
		
## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	player.equipment.thrown_weapon()
	
	transition_state(Player.State.MOVING)	## Emit the signal and transition back to Moving
