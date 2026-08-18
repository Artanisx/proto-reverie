class_name PlayerStateKicking
extends PlayerState

## Player State: Kicking
##
## This handles the behaviour for the player state: State.KICKING
## It contains all processing, signals, etc required for this state
## Transitions:
## Kicking > Moving

const GROUND_FRICTION: float = 10.0 ## How quickly the player stops moving after starting to kick
		
## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the throw animation
	player.animation_player.play("kick")
	
	## Check if we're colliding with a door or enemy and handle it accordingly	
	if player.kick_raycast.is_colliding():
		var collider := player.kick_raycast.get_collider() as Node
		
		## Is it a door?
		if collider is Door:		
			var door := collider as Door			
			AudioManager.play("door-kick", player.action_audio_stream_player) ## Play SFX
			door.open(player.global_transform)	## open it
		## Is it an enemy?
		elif collider is Enemy:
			var enemy := collider as Enemy
			AudioManager.play("kick", player.action_audio_stream_player) ## Play SFX
			enemy.try_receive_kick(player)	## issue the kick to the enemy
	else:
		## Player kicks nothing!
		AudioManager.play("kick-swoosh", player.action_audio_stream_player) ## Play SFX
				
	## Hookup to the finish signal
	player.animation_player.animation_finished.connect(on_animation_finished)
	
func _physics_process(delta: float) -> void:
	## Slow down to zero while kicking
	player.velocity = player.velocity.move_toward(Vector3.ZERO, delta * GROUND_FRICTION)
	
func on_animation_finished(_animation_name: String) -> void:	
	## Emit the signal and transition back to Moving
	transition_state(Player.State.MOVING)	
