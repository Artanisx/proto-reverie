class_name EnemyStateMoving
extends EnemyState

## Enemy State: Moving
##
## This handles the behaviour for the Enemy state: State.MOVING
## It contains all processing, signals, etc required for this state
## Transitions:
## Moving > Slashing
## Moving > Hurt NYI
## Moving > Impaling NYI
## Moving > Dying NYI

func _enter_tree() -> void:
	enemy.animation_player.play("idle")
	
func _physics_process(_delta: float) -> void:
	if enemy.has_registered_player():
		if enemy.is_player_within_reach() and can_attack():
			# Enemyu is attacking so this is their new "last attack"
			enemy.time_since_last_attack = Time.get_ticks_msec()
			# Transition to the Slashing state
			transition_state(enemy.State.SLASHING)

## This function return true if enough time has passed since the last attack
## Basically checking if the enemy can attack again already
func can_attack() -> bool:
	return Time.get_ticks_msec() - enemy.time_since_last_attack > enemy.duration_between_attacks
