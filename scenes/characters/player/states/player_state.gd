class_name PlayerState
extends Node

## Player State base class
##
## This contains code that is shared between all Player States, that are extension of this class

## Signal for when a transition is requested, with the new state as argument
signal transition_requested(new_state: Player.State)

var player: Player

## Initialize this state[br]
## Requires a player reference
func _init(source_player: Player) -> void:
	player = source_player	## Store the player reference

## This function emits the transition_state signal
func transition_state(new_state: Player.State) -> void:
	transition_requested.emit(new_state)
	
## Calculate wheter the player can be hurt
## Genericly is always true, but in states that disallows to be hurt, this will be overridden as false
func can_get_hurt() -> bool:
	return true
