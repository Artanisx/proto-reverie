class_name ExpComponent
extends Node

## Exp Component
##
## This is a component that can be added to Player or other entities  for handling their experience and levels.

@export var max_exp: int ## How much experience is required to a level up
@export var current_exp: int ## How much experience the player has in the current level
@export var max_level: int ## Level cap
@export var current_level: int ## Current level

var is_max_level: bool = false

## Increase the experience by the passed argument, takes care of level ups
func gain_experience(exp: int) -> void:
	if is_max_level:
		return	## Can't gain experience if it's max level
			
	if current_exp + exp >= max_exp:		
		## Player gains a level
		## Store excess experience for the next level
		var excess_exp: int = (current_exp + exp) - max_exp
		if excess_exp > 0:
			gain_level(excess_exp)
		else:
			gain_level()
	else:
		## Player simply gains exp
		current_exp = current_exp + exp
		print("Player gains experience: (" + str(exp) + ") - Current Exp:"  + str(current_exp) + "/" + str(max_exp))
	
## Increases the level
## Takes an optional paramenter with excess experience
func gain_level(excess_experience: int = 0) -> void:	
	## Attemp to level up
	if current_level + 1 < max_level:
		current_level += 1
		current_exp = 0 ## Make sure to reset experience after a level up
		print("Player gains a level: (" + str(current_level) + ")")
		GameEvents.level_up.emit()
		## Set the experience
		if excess_experience > 0:
			gain_experience(excess_experience) ## EXP carries over, but invoking gain_experience to account for extra levels
		else:
			current_exp = 0 ## New level starts at 0 exp
	else:
		## Player is capped, no level up possible
		current_level = max_level
		current_exp = 0
		is_max_level = true
		print("Player cannot level up anymore. Level is: (" + str(current_level) + ")")
		
	
		
			
