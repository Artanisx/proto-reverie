class_name PlayerStateBlocking
extends PlayerState

## Player State: Blocking
##
## This handles the behaviour for the player state: State.BLOCKING
## It contains all processing, signals, etc required for this state
## Transitions:
## Blocking > Moving

const GROUND_FRICTION: float = 10.0 ## How quickly the player stops moving after starting to block
		
## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the throw animation
	player.animation_player.play("block")
	
	## Hookup to the finish signal
	player.animation_player.animation_finished.connect(on_animation_finished)

## Let's make sure the player can move while blocking
func _physics_process(delta: float) -> void:
	## Slow down to zero while blocking
	player.velocity = player.velocity.move_toward(Vector3.ZERO, delta * GROUND_FRICTION)
	
func on_animation_finished(_animation_name: String) -> void:	
	## Emit the signal and transition back to Moving
	transition_state(Player.State.MOVING)	
