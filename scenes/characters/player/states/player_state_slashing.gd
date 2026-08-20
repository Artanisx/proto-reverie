class_name PlayerStateSlashing
extends PlayerState

## Player State: Slashing
##
## This handles the behaviour for the player state: State.SLASHING
## It contains all processing, signals, etc required for this state
## Transitions:
## Slashing > Moving

const TIME_EMIT_DAMAGE: int = 200 # How many milliseconds after the player slash animation is started, the damage should be emitted. This is to avoid the enemy getting damage when the player is charging the slash.
const WEAPON_DURABILITY_DAMAGE: int = 2 # how much the weapon is damanged by a slash hitting an enemy

var has_emitted_damage: bool = false # To emit damage only once per slash
var time_start_slash: int = Time.get_ticks_msec()	# Var to store the time since start slashing, used with the TIME_EMIT_DAMAGE constant to time the damage mission


## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the slash animation
	player.animation_player.play("slash")
	
	## Hookup to the finish signal
	player.animation_player.animation_finished.connect(on_animation_finished)	
		
func _process(_delta: float) -> void:
	## Start the timer
	var time_elasped := Time.get_ticks_msec() - time_start_slash
	
	## Check if it's time to emit damage (only once) and only after the right moment (200 ms)
	if not has_emitted_damage and time_elasped > TIME_EMIT_DAMAGE:
		has_emitted_damage = true
		
		## Check wheter an enemy is in reach (so it will get it) - only emit damage if weapon collided
		if player.weapon_reach_raycast.is_colliding():
			var enemy := player.weapon_reach_raycast.get_collider() as Enemy
			if enemy != null:
				var damage := player.equipment.weapon_data.get_damage_dealt() + player.player_strength ## Include player stregnth in damage calculation
				## Damage the weapon itself
				player.equipment.apply_weapon_damage(WEAPON_DURABILITY_DAMAGE)
				enemy.try_receive_hit(player, damage)	 ## try to hit the enemy that collided with the raycast, passing the player (for position) and damage	
		else:
			##the player doesn't hit anything
			AudioManager.play("slash", player.action_audio_stream_player) ## Play the SFX
				
		
## Since we want to be able to move while slashing, we call player.process() super
func _physics_process(delta: float) -> void:
	## Process Movement
	player.process_movement(delta)
	
func on_animation_finished(_animation_name: String) -> void:	
	transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
