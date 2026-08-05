class_name EnemyStateHurt
extends EnemyState

## Enemy State: Hurt
##
## This handles the behaviour for the Enemy state: State.HURT
## It contains all processing, signals, etc required for this state
## Transitions:
## Hurt > Moving

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the slash animation
	enemy.animation_player.play("hurt")
	
	## Hookup to the finish signal
	enemy.animation_player.animation_finished.connect(on_animation_finished)
	
func on_animation_finished(_animation_name: String) -> void:	
	transition_state(Enemy.State.MOVING)	## Emit the signal and transition to Moving
