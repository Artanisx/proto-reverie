class_name World
extends Node3D

const LEVEL := preload("res://scenes/levels/test_procedural_level.tscn")

## LIST OF LEVELS - ONLY USED BY TUTORIAL 
##const LEVELS := [preload("res://scenes/levels/level_01_welcome.tscn")] ## Only used by tutorial

##var current_level_index := 0  ## Only used by tutorial
var current_loaded_level : BaseProceduralLevel = null

func _ready() -> void:
	## Connect the signal for restart 
	GameEvents.level_restarted.connect(on_level_restarted)
		
	load_level(0) ## load test level
	
## Add a base procedural level node to the level which will hold the level itself
func load_level(_index: int) -> void:	
	## If there's a level loaded, clear it out
	if current_loaded_level != null:
		current_loaded_level.queue_free()
	
	## Instantiate the level (base cprocedfural level for now)
	## TODO: This should NOT be a set scene, but generated directly so values like criticalpath legnth etc can be set via code
	## THAT woudl also allow for a restart_harder function with bigger values, that could be simply bigger than the previous run
	current_loaded_level = LEVEL.instantiate()
	GameState.register_level(current_loaded_level)	 ## Register the currently loaded level
	add_child(current_loaded_level)

## Function to restart the Level
func on_level_restarted() -> void:
	## Just load the level again passing the current level (restarting THIS level)
	load_level(0)
