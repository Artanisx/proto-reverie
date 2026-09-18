class_name PlayerStateShooting
extends PlayerState

## Player State: Shooting
##
## This handles the behaviour for the player state: State.SHOOTING
## It contains all processing, signals, etc required for this state
## Transitions:
## Shooting > Moving

const WEAPON_DURABILITY_DAMAGE: int = 1 # how much bullet costs shooting 

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Get the gun scene
	var weapon : EquippedItem
	var anim_player: AnimationPlayer
	
	for child in player.equipment.main_camera.get_children():
		if child is EquippedItem:
			weapon = child	
	
	if weapon != null:
		if player.can_range_attack(): ## Check if the player is allowed to shoot		
			if weapon.weapon_data.condition > 0: ## Shoot only if you have a bullet
				## Play the Shoot animation
				anim_player = weapon.get_animation_player()
				if anim_player != null:
					anim_player.play("Shoot")
					## Reset the shoot timer
					player.time_since_last_range_attack = Time.get_ticks_msec()
					## Hookup to the finish signal
					anim_player.animation_finished.connect(on_animation_finished)	
				else:
					printerr("ERROR in PLAYER_STATE_SHOOTING: No gun found. Moving back to Player.State.Moving right away")
					transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
					return		
		else:
			##player tried to shoot before it was allowed, transition back to moving
			print("No shooty while cooldowny!")
			transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
		

## Since we want to be able to move while shooting, we call player.process() super
func _physics_process(delta: float) -> void:
	## Process Movement
	player.process_movement(delta)

func on_animation_finished(_animation_name: String) -> void:	
	## HANDLE THE SHOOTING
	player.equipment.shoot_with_gun()
	
	## PLAY SFX
	AudioManager.play("pick-up", player.action_audio_stream_player) ## Plays the SFX after the bullet is shot
	
	##Damage the gun (NOT SURE MIGHT BE DISABLED)
	player.equipment.apply_weapon_damage(WEAPON_DURABILITY_DAMAGE)
	
	transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
