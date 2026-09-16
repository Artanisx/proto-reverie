class_name PlayerStateShooting
extends PlayerState

## Player State: Shooting
##
## This handles the behaviour for the player state: State.SHOOTING
## It contains all processing, signals, etc required for this state
## Transitions:
## Shooting > Moving NYI

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	print("[DEBUG] Entered shooting state!")
	
## Since we want to be able to move while shooting, we call player.process() super
func _physics_process(delta: float) -> void:
	## Process Movement
	player.process_movement(delta)
