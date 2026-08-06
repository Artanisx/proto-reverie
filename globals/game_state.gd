extends Node

## Game State
##
## This is a Global accesible to all the game. Takes care of registering a player refernece and the current level reference.

var current_level : BaseLevel
var current_player : Player

## Set the current level
func register_level(level: BaseLevel) -> void:
	current_level = level

## Set the current player
func register_player(player: Player) -> void:
	current_player = player
