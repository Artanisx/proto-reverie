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
	## Play the throw animation
	player.animation_player.play("throw_weapon")
	
	## Hookup to the finish signal
	player.animation_player.animation_finished.connect(on_animation_finished)

## Let's make sure the player can move while throwing
func _physics_process(delta: float) -> void:
	player.process_movement(delta)
	
func on_animation_finished(_animation_name: String) -> void:
	## Throw the weapon
	player.equipment.thrown_weapon() 
	
	## Emit the signal and transition back to Moving
	transition_state(Player.State.MOVING)	
