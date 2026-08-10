class_name EnemyStateStunned
extends EnemyState

## Enemy State: Stunned
##
## This handles the behaviour for the Enemy state: State.STUNNED
## It contains all processing, signals, etc required for this state
## Transitions:
## Stunned > Moving

const GROUND_FRICTION: float = 10.0 ## How quickly the enemy stops moving after starting to be stunned
const KNOCKBACK_FORCE: float = 2.0 ## The force of knockback suffered when hit

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:			
	## Play the stun animation
	enemy.animation_player.play("stunned")
	
	## Apply some pushback force from the direction of the impact (player)
	enemy.pushback_force += state_data.impact_direction * KNOCKBACK_FORCE	
	
	## Start the  stunned timer		
	var timer := get_tree().create_timer(enemy.duration_stun)	## Create atimer of the set duration
	timer.timeout.connect(on_stun_finish)						## Set its callback rto the timeout signal

func _physics_process(delta: float) -> void:
	## Slow down the enemy back to zero after the pushback
	enemy.velocity = enemy.velocity.move_toward(Vector3.ZERO, delta * GROUND_FRICTION)
	
	## Process the movement
	enemy.process_movement(delta)	
	
## This will transition back to the moving state[br]
func on_stun_finish() -> void:	
	transition_state(Enemy.State.MOVING)	
	
## Override this because enemy CAN be hurt in the stunned state
func can_get_hurt() -> bool:
	return true
