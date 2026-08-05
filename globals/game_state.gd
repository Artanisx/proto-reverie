extends Node

var current_level : BaseLevel
var current_player : Player

## Set the current level
func register_level(level: BaseLevel) -> void:
	current_level = level

## Set the current player
func register_player(player: Player) -> void:
	current_player = player
