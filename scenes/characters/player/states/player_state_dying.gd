class_name PlayerStateDying
extends PlayerState

## Player State: Dying
##
## This handles the behaviour for the Player state: State.Dying
## It contains all processing, signals, etc required for this state
## Transitions:
## Dying > Dead NYI

func _enter_tree() -> void:	
	## 0.1 - Apply the Hit Stop juice for highlighting the action - This will pause the game for a bit.
	GameEvents.impact_felt.emit(GameEvents.ImpactIntensity.MEDIUM)
		
	## 0.2 - Instnatiate the blododpusrt node from the head
	##FxHelper.create_blood_fx(enemy.physical_bone_head.global_transform)
	
	## 0.3 - Drop the weapon
	player.equipment.drop_weapon()
	
	## 0.4 - Drop the furniture
	player.equipment.drop_furniture()
	
	## 0.5 - Drop the shield
	player.equipment.drop_shield()
	
	print("dead!!!!")


## Since we're already Dying, we cannot get hurt again (i.e. acid trap)
func can_get_hurt() -> bool:
	return false

## Since we're already Dying, we cannot die again!
func can_die() -> bool:
	return false
