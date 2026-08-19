class_name World
extends Node3D

@onready var minimap_camera: MinimapCamera = $MarginContainer/PanelContainer/Minimap/SubViewport/MinimapCamera

@onready var test_procedural_level: BaseProceduralLevel = $TestProceduralLevel

## LIST OF LEVELS - ONLY USED BY TUTORIAL 
##const LEVELS := [preload("res://scenes/levels/level_01_welcome.tscn")] ## Only used by tutorial

var current_level_index := 0  ## Only used by tutorial
var current_loaded_level : BaseLevel = null  ## Only used by tutorial


func _ready() -> void:
	minimap_camera.minimap_ready.connect(on_minimap_ready.bind())
	GameState.register_level(test_procedural_level)	 ## Register the currently loaded level
	
	## Connect the signal for restart - ONLY USED BY TUTORIAL 
	##GameEvents.level_restarted.connect(on_level_restarted)	## Only used by tutorial
	##load_level(current_level_index) ## Only used by tutorial

func on_minimap_ready() -> void:
	##print("received minimap readyness")
	minimap_camera.set_player(test_procedural_level.get_player())


## WARNING: ONLY USED BY TUTORIAL 	
## Add a BaseLevel node to the level which will hold the level itself
#func load_level(index: int) -> void:	
	### If there's a level loaded, clear it out
	#if current_loaded_level != null:
		#current_loaded_level.queue_free()
	#
	### Instantiate the level
	#if LEVELS.size() > index:
		## Instantiate it
		#current_loaded_level = LEVELS[index].instantiate()
		#GameState.register_level(current_loaded_level)	 ## Register the currently loaded level
		#add_child(current_loaded_level)

## WARNING: ONLY USED BY TUTORIAL
## Function to restart the Level
#func on_level_restarted() -> void:
	### Just load the level again passing the current level (restarting THIS level)
	#load_level(current_level_index)
