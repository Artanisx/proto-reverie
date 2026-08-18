class_name EnemyStateDying
extends EnemyState

## Enemy State: Dying
##
## This handles the behaviour for the Enemy state: State.Dying
## It contains all processing, signals, etc required for this state
## Transitions:
## Dying > Dead

const DURATION_RAGDOLL_SIMULATION : float = 3.0

func _enter_tree() -> void:	
	## 0.1 - Apply the Hit Stop juice for highlighting the action - This will pause the game for a bit.
	GameEvents.impact_felt.emit(GameEvents.ImpactIntensity.MEDIUM)
		
	## 0.2 - Instnatiate the blododpusrt node from the head
	FxHelper.create_blood_fx(enemy.physical_bone_head.global_transform)
	
	## 0.3 - Drop the weapon
	enemy.equipment.drop_weapon()
	
	## 0.4 - Emit the dying sound effect
	AudioManager.play("orc-die", enemy.vocal_audio_stream_player) ## Play SFX
	
	## 0.5 - Drop the shield
	enemy.equipment.drop_shield()
	
	## 0.6 - Turn of the Presence Light
	enemy.presence_light.visible = false	
	
	## 1- Disable collision shape since we are no longer handling phsyics with it
	enemy.collision_shape.disabled = true
	## 2- Enable the skeleton simulator
	enemy.skeleton_simulator.active = true
	## 3- Start the simulation (ragdoll)
	enemy.skeleton_simulator.physical_bones_start_simulation() ## we could only specific which bones are able to move, for example only the feet if mipaled to a wall, here we pass them all because we want them to all move)
	## 4- APply the impulse force t  othe torso since the weapon attaches itself to the torso
	enemy.physical_bone_torso.apply_impulse(state_data.impulse)
	## 5- After a few seconds, let's stop the simulation so parts don't keep wobbling
	var timer := get_tree().create_timer(DURATION_RAGDOLL_SIMULATION)	## Create atimer of the set duration
	timer.timeout.connect(freeze_ragdoll)								## Set its callback rto the timeout signal

## This will transition to the DEAD state[br]
## This will [code]freeze[/code] the ragdoll simulation
func freeze_ragdoll() -> void:
	transition_state(Enemy.State.DEAD)
	
## Since we're already Dying, we cannot die again!
func can_die() -> bool:
	return false
