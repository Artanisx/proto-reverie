class_name EnemyStateStunned
extends EnemyState

## Enemy State: Stunned
##
## This handles the behaviour for the Enemy state: State.STUNNED
## It contains all processing, signals, etc required for this state
## Transitions:
## Stunned > Moving
## Stunned > Stunned (prolong a stun)

const GROUND_FRICTION: float = 10.0 ## How quickly the enemy stops moving after starting to be stunned
const KNOCKBACK_FORCE: float = 2.0 ## The force of knockback suffered when hit

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:			
	## Play the stun animation
	enemy.animation_player.play("stunned")
	
	## Check if we have a knockback_force in the data, if so override and use that
	var knockback_force :=  KNOCKBACK_FORCE
	if state_data.knockback_force != 0:
		knockback_force = state_data.knockback_force
	
	## Apply some pushback force from the direction of the impact (player)
	enemy.pushback_force += state_data.impact_direction * knockback_force	
	
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
	## scream after the stun is over to aggro the rest 
	enemy.screamed.emit()	
	transition_state(Enemy.State.MOVING)	
	
## Override this because enemy CAN be hurt in the stunned state
func can_get_hurt() -> bool:
	return true
	
## Override this because enemy CAN be stunned and stay in the stunned state (stun lock)
func can_get_stunned() -> bool:
	return true
