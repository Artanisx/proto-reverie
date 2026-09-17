class_name PlayerStateShooting
extends PlayerState

## Player State: Shooting
##
## This handles the behaviour for the player state: State.SHOOTING
## It contains all processing, signals, etc required for this state
## Transitions:
## Shooting > Moving

const WEAPON_DURABILITY_DAMAGE: int = 1 # how much the weapon is damanged by a shooting -- Might be disabled

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Get the gun scene
	var weapon : EquippedItem
	var anim_player: AnimationPlayer
	
	for child in player.equipment.main_camera.get_children():
		if child is EquippedItem:
			weapon = child	
	
	if weapon != null:
		## Play the Shoot animation
		anim_player = weapon.get_animation_player()
		if anim_player != null:
			anim_player.play("Shoot")
		else:
			printerr("ERROR in PLAYER_STATE_SHOOTING: No gun found. Moving back to Player.State.Moving right away")
			transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
			return
		
	## Hookup to the finish signal
	anim_player.animation_finished.connect(on_animation_finished)	

## Since we want to be able to move while shooting, we call player.process() super
func _physics_process(delta: float) -> void:
	## Process Movement
	player.process_movement(delta)

func on_animation_finished(_animation_name: String) -> void:	
	## HANDLE THE SHOOTING
	player.equipment.shoot_with_gun()
	
	##Damage the gun (NOT SURE MIGHT BE DISABLED)
	player.equipment.apply_weapon_damage(WEAPON_DURABILITY_DAMAGE)
	
	transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
