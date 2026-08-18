class_name EnemyStateHurt
extends EnemyState

## Enemy State: Hurt
##
## This handles the behaviour for the Enemy state: State.HURT
## It contains all processing, signals, etc required for this state
## Transitions:
## Hurt > Moving
## Hurt > Dying

const KNOCKBACK_FORCE: float = 2.0 ## The force of knockback suffered when hit

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Take damage
	enemy.health.take_damage(state_data.damage)
	
	## Refresh HP UI
	enemy.health_indicator.refresh(enemy.health.current_life, enemy.health.max_life)
	
	## Apply some pushback force from the direction of the impact (player)
	enemy.pushback_force += state_data.impact_direction * KNOCKBACK_FORCE	
	
	## Check wheter the enemy is still alive
	if enemy.health.is_dead():
		AudioManager.play("hit-kill", enemy.action_audio_stream_player) ## Play the SFX
		## Apply an inpulse so that there's a knockback also when dying from a hit
		var data := EnemyStateData.new().set_impulse(state_data.impact_direction * 120.0 + Vector3.UP * 80)
		transition_state(Enemy.State.DYING, data)	## Emit the signal and transition to Dying
	else:	
		AudioManager.play("slash-hit", enemy.action_audio_stream_player) ## Play the SFX
		## Apply the Hit Stop juice for highlighting the action - This will briefly pause the game
		GameEvents.impact_felt.emit(GameEvents.ImpactIntensity.LOW)
		
		## Instnatiate the blododpusrt node from the head, but without sparks for a simple hit
		FxHelper.create_blood_fx(enemy.physical_bone_head.global_transform, false)
		
		## Play the hurt animation
		enemy.animation_player.play("hurt")
		
		## Hookup to the finish signal
		enemy.animation_player.animation_finished.connect(on_animation_finished)

func _physics_process(delta: float) -> void:
	enemy.process_movement(delta) ## We need to process the movement
	
func on_animation_finished(_animation_name: String) -> void:	
	transition_state(Enemy.State.MOVING)	## Emit the signal and transition to Moving
