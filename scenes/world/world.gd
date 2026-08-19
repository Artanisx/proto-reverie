class_name World
extends Node3D

## LIST OF LEVELS 
const LEVELS := [preload("res://scenes/levels/level_01_welcome.tscn")]

var current_level_index := 0
var current_loaded_level : BaseLevel = null

func _ready() -> void:
	## Connect the signal for restart
	GameEvents.level_restarted.connect(on_level_restarted)
	
	load_level(current_level_index)
	

## Add a BaseLevel node to the level which will hold the level itself
func load_level(index: int) -> void:	
	## If there's a level loaded, clear it out
	if current_loaded_level != null:
		current_loaded_level.queue_free()
	
	## Instantiate the level
	if LEVELS.size() > index:
		# Instantiate it
		current_loaded_level = LEVELS[index].instantiate()
		GameState.register_level(current_loaded_level)	 ## Register the currently loaded level
		add_child(current_loaded_level)

## Function to restart the Level
func on_level_restarted() -> void:
	## Just load the level again passing the current level (restarting THIS level)
	load_level(current_level_index)
