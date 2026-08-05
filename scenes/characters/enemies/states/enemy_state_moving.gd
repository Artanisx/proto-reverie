class_name EnemyStateMoving
extends EnemyState

## Enemy State: Moving
##
## This handles the behaviour for the Enemy state: State.MOVING
## It contains all processing, signals, etc required for this state
## Transitions:
## Moving > Slashing
## Moving > Hurt
## Moving > Impaling
## Moving > Dying

const SPEED_ROTATION : float = 10.0

func _enter_tree() -> void:
	enemy.animation_player.play("idle")
	
func _physics_process(delta: float) -> void:
	if enemy.has_registered_player():
		## FIrst we save the Y commponent of the enemy transform so we can be sure it is not altered during the rotation
		var target_position := enemy.player.global_position		## we get the player position
		target_position.y = enemy.global_position.y ## vertically we save the ENEMY (this) position to avoid altering it facing the player with te whole body
		
		## Face the player, so calculate the rotation that the enemy needs to perform to look at the player
		var target_transform: Transform3D = enemy.global_transform.looking_at(target_position)
		
		## slowly rotate towards that target transform (to face the player)
		enemy.global_basis = enemy.global_basis.slerp(target_transform.basis, delta * SPEED_ROTATION)		
		
		if enemy.is_player_within_reach():
			## First, we play the idle animation and stop moving 
			enemy.animation_player.play("idle")
			enemy.velocity = Vector3(0, enemy.velocity.y, 0)
			if can_attack():
				# Enemyu is attacking so this is their new "last attack"
				enemy.time_since_last_attack = Time.get_ticks_msec()
				# Transition to the Slashing state in order to attack
				transition_state(enemy.State.SLASHING)
		else:
			## player is NOT within reach, so the enemy should close the distance in order to enter melee range
			
			## Play the run animation
			enemy.animation_player.play("run")
			
			## Set the navigation agent
			## In order to do that, the room must have a Navigation Region 3D baked (either pre, or during run time)
			
			## Pass the target position where we want the enemy to go to the nav agent so it knows where to go
			enemy.nav_agent.target_position = target_position
			
			## Run through the astar alghoritm and find the next destination to get from current to target-pos
			var next_path_position := enemy.nav_agent.get_next_path_position()
			
			## Calculate the direction from the enemy to the next destination
			var direction := enemy.global_position.direction_to(next_path_position)	
			
			## Set the velocity (so the enemy will move accordingly)
			enemy.velocity = direction * enemy.speed			
			
		## Make sure we process enemy movement or else any change to velocity will do nothing as move_and_slide() call is required to make them effective
		enemy.process_movement(delta)


## This function return true if enough time has passed since the last attack
## Basically checking if the enemy can attack again already
func can_attack() -> bool:
	return Time.get_ticks_msec() - enemy.time_since_last_attack > enemy.duration_between_attacks
