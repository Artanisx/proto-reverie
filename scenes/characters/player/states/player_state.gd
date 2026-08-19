class_name PlayerState
extends Node

## Player State base class
##
## This contains code that is shared between all Player States, that are extension of this class

## Signal for when a transition is requested, with the new state as argument
signal transition_requested(new_state: Player.State, source_data: PlayerStateData)

var state_data: PlayerStateData
var player: Player

## Initialize this state[br]
## Requires a player reference, optionally a PLayerStateData
func _init(source_player: Player, source_data: PlayerStateData = PlayerStateData.new()) -> void:
	player = source_player	## Store the player reference
	state_data = source_data ## Store the playerstatedata reference containing damage/impact direction etc

## This function emits the transition_state signal, takes the new state and optionally a PlayerStateData for parameters
func transition_state(new_state: Player.State, source_data: PlayerStateData = PlayerStateData.new()) -> void:
	transition_requested.emit(new_state, source_data)
	
## Calculate wheter the player can be hurt
## Genericly is always true, but in states that disallows to be hurt, this will be overridden as false
func can_get_hurt() -> bool:
	return true

## Calculate wheter the player can die
## Genericly is always true, but in states that disallows being killed, this will be overridden as false
func can_die() -> bool:
	return true
