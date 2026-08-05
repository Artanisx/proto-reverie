class_name PlayerStateSlashing
extends PlayerState

## Player State: Slashing
##
## This handles the behaviour for the player state: State.SLASHING
## It contains all processing, signals, etc required for this state
## Transitions:
## Slashing > Moving

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the slash animation
	player.animation_player.play("slash")
	
	## Hookup to the finish signal
	player.animation_player.animation_finished.connect(on_animation_finished)
	
## Since we want to be able to move while slashing, we call player.process() super
func _physics_process(delta: float) -> void:
	## Process Movement
	player.process_movement(delta)
	
func on_animation_finished(_animation_name: String) -> void:	
	transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
