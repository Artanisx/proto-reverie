extends Node

## Game State
##
## This is a Global accesible to all the game. Takes care of registering a player refernece and the current level reference.
## It also store the inventory for the player (only the keys for now)

var current_level : BaseProceduralLevel
var current_player : Player
var current_keys : Dictionary[Door.KeyColor, bool] = {} ## This will store which keys (true/false) of each color the player has

var number_of_kills : int = 0 ## Stores the number of kills for the Victory Screen
var end_time : String ## Stores the end time in HH:MM:SS format

## Check if the player has the passed Door.KeyColor key.
func has_key(color: Door.KeyColor) -> bool:
	return current_keys.get(color, false) ## Return wheter the player has the passed color. False if the dictionary key (not DoorKey) is not found!

## Expends the key
func use_key(color: Door.KeyColor) -> void:
	if has_key(color):
		current_keys[color] = false ## this key has been used and thus destroyed
		GameEvents.current_keys_changed.emit(color) ## Emit the signal as the keys changed
		
## Grant the key (for when the player picks it up)
func obtain_key(color: Door.KeyColor) -> void:
	if not has_key(color):
		current_keys[color] = true ## this key has been granted
		GameEvents.current_keys_changed.emit(color) ## Emit the signal as the keys changed

## Set the current level
func register_level(level: BaseProceduralLevel) -> void:
	current_level = level
	current_keys = {} ##Reset the keys inventory

## Set the current player
func register_player(player: Player) -> void:
	current_player = player	
	
## Add to the enemy kills
func add_enemy_counter(amount: int = 1) -> void:
	if amount > 0:
		number_of_kills += amount
