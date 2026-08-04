class_name EnemyStateMoving
extends EnemyState

## Enemy State: Moving
##
## This handles the behaviour for the Enemy state: State.MOVING
## It contains all processing, signals, etc required for this state
## Transitions:
## Moving > Impaling
## Moving > Dying

func _enter_tree() -> void:
	enemy.animation_player.play("idle")
