class_name EnemyStateSlashing
extends EnemyState

## Enemy State: Moving
##
## This handles the behaviour for the Enemy state: State.SLASHING
## It contains all processing, signals, etc required for this state
## Transitions:
## Slashing > Moving
## Slashing > Stunned

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the slash animation
	enemy.animation_player.play("slash")
	
	## Hookup to the finish signal
	enemy.animation_player.animation_finished.connect(on_animation_finished)
	
func on_animation_finished(_animation_name: String) -> void:	
	transition_state(Enemy.State.MOVING)	## Emit the signal and transition to Moving
	
## Overrid the can_get_stunned() function to return true to allow a stun from this state
func can_get_stunned() -> bool:
	return true
