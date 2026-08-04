class_name EnemyState
extends Node

## Enemy State base class
##
## This contains code that is shared between all Enemy States, that are extension of this class

## Signal for when a transition is requested, with the new state as argument
signal transition_requested(new_state: Enemy.State, source_data: EnemyStateData)

var enemy: Enemy
var state_data: EnemyStateData

## Initialize this state[br]
## Requires a enemy reference
func _init(source_enemy: Enemy, source_data: EnemyStateData = EnemyStateData.new()) -> void:
	enemy = source_enemy	## Store the enemy reference
	state_data = source_data	## Store the enemy data reference so we have all variables we need

## This function emits the transition_state signal
func transition_state(new_state: Enemy.State, source_data: EnemyStateData = EnemyStateData.new()) -> void:
	transition_requested.emit(new_state, source_data)
