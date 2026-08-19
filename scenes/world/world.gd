class_name World
extends Node3D

@onready var minimap_camera: MinimapCamera = $MarginContainer/PanelContainer/Minimap/SubViewport/MinimapCamera

const LEVEL := preload("res://scenes/levels/test_procedural_level.tscn")

## LIST OF LEVELS - ONLY USED BY TUTORIAL 
##const LEVELS := [preload("res://scenes/levels/level_01_welcome.tscn")] ## Only used by tutorial

##var current_level_index := 0  ## Only used by tutorial
var current_loaded_level : BaseProceduralLevel = null

func _ready() -> void:
	minimap_camera.minimap_ready.connect(on_minimap_ready.bind())
	
	## Connect the signal for restart 
	GameEvents.level_restarted.connect(on_level_restarted)	
	load_level(0) ## load test level

func on_minimap_ready() -> void:
	##print("received minimap readyness")
	minimap_camera.set_player(current_loaded_level.get_player())


## Add a base procedural level node to the level which will hold the level itself
func load_level(_index: int) -> void:	
	## If there's a level loaded, clear it out
	if current_loaded_level != null:
		current_loaded_level.queue_free()
	
	## Instantiate the level (base cprocedfural level for now)
	current_loaded_level = LEVEL.instantiate()
	GameState.register_level(current_loaded_level)	 ## Register the currently loaded level
	add_child(current_loaded_level)

## Function to restart the Level
func on_level_restarted() -> void:
	## Just load the level again passing the current level (restarting THIS level)
	load_level(0)
