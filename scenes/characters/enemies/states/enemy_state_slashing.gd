class_name EnemyStateSlashing
extends EnemyState

## Enemy State: Moving
##
## This handles the behaviour for the Enemy state: State.SLASHING
## It contains all processing, signals, etc required for this state
## Transitions:
## Slashing > Moving
## Slashing > Stunned

const TIME_EMIT_DAMAGE: int = 200 # How many milliseconds after the enemy slash animation is started, the damage should be emitted. This is to avoid the player getting damage when the enemy is charging the slash.

var has_emitted_damage: bool = false # To emit damage only once per slash
var time_start_slash: int = Time.get_ticks_msec()	# Var to store the time since start slashing, used with the TIME_EMIT_DAMAGE constant to time the damage mission


## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the slash animation
	enemy.animation_player.play("slash")
	
	## Hookup to the finish signal
	enemy.animation_player.animation_finished.connect(on_animation_finished)
	
func _process(_delta: float) -> void:
	## Start the timer
	var time_elasped := Time.get_ticks_msec() - time_start_slash
	
	## Check if it's time to emit damage (only once) and only after the right moment (200 ms)
	if not has_emitted_damage and time_elasped > TIME_EMIT_DAMAGE:
		has_emitted_damage = true
		
		## Check wheter the player is in reach (so it will get it) - only emit damage if weapon collided
		if enemy.weapon_reach_raycast.is_colliding():
			var player := enemy.weapon_reach_raycast.get_collider() as Player
			if player != null:
				var damage := enemy.equipment.weapon_data.get_damage_dealt()				
				player.try_receive_hit(enemy, damage)	 ## try to hit the player that collided with the raycast, passing the enemy (for position) and damage	
		else:
			## Enemy didn't hit anything (swish!!)
			AudioManager.play("slash", enemy.action_audio_stream_player) ## PLay the SFX	
	
func on_animation_finished(_animation_name: String) -> void:	
	transition_state(Enemy.State.MOVING)	## Emit the signal and transition to Moving
	
## Overrid the can_get_stunned() function to return true to allow a stun from this state
func can_get_stunned() -> bool:
	return true
