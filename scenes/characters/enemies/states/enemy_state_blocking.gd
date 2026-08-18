class_name EnemyStateBlocking
extends EnemyState

## Enemy State: Blocking
##
## This handles the behaviour for the Enemy state: State.BLOCKING
## It contains all processing, signals, etc required for this state
## Transitions:
## Blocking > Moving

const GROUND_FRICTION: float = 10.0 ## How quickly the enemy stops moving after starting to block

const KNOCKBACK_FORCE: float = 2.0 ## The force of knockback suffered when hit

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:			
	## Play the slash animation
	enemy.animation_player.play("block")
	
	## Apply some visual effect (hit stop and camera shake atm respond to this signal)
	GameEvents.impact_felt.emit(GameEvents.ImpactIntensity.LOW)
	## Also instantiate metal sparks from the shield
	FxHelper.create_metal_spark_fx(enemy.equipment.shield_placeholder.global_position)
	
	## Play SFX
	AudioManager.play("block", enemy.action_audio_stream_player)
	
	## Apply some pushback force from the direction of the impact (player)
	enemy.pushback_force += state_data.impact_direction * KNOCKBACK_FORCE	
	
func _physics_process(delta: float) -> void:
	## Slow down the enemy back to zero after the pushback
	enemy.velocity = enemy.velocity.move_toward(Vector3.ZERO, delta * GROUND_FRICTION)
	
	## Process the movement
	enemy.process_movement(delta)
	
	## Check if the enemy came to a full stop after slowing down, if so the state goes back to Enemy.Moving
	if enemy.velocity == Vector3.ZERO:	
		transition_state(Enemy.State.MOVING)	## Emit the signal and transition to Moving
