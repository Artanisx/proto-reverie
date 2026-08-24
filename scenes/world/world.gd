class_name World
extends Node3D

const BASE_PROCEDURAL_LEVEL := preload("res://scenes/levels/base_procedural_level.tscn")

const DEFAULT_SIZE : Vector2i = Vector2i(8,8)
const DEFAULT_CRITICAL_LENGTH : int = 13
const DEFAULT_BRANCHES : int = 3
const DEFAULT_BRANCHES_SIZE : Vector2i = Vector2i(1,4)

var current_loaded_level : BaseProceduralLevel = null

func _ready() -> void:
	## Connect the signal for restart 
	GameEvents.level_restarted.connect(on_level_restarted)
	
	## Connect the signal for restart 
	GameEvents.level_harder_restarted.connect(on_level_harder_restarted)
		
	load_level() ## load test level
	
## Add a base procedural level node to the level which will hold the level itself
func load_level(level_size: Vector2i = DEFAULT_SIZE, cp_length: int = DEFAULT_CRITICAL_LENGTH, branches: int = DEFAULT_BRANCHES, branch_length: Vector2i = DEFAULT_BRANCHES_SIZE) -> void:	
	## If there's a level loaded, clear it out
	if current_loaded_level != null:
		current_loaded_level.queue_free()
	
	current_loaded_level = BASE_PROCEDURAL_LEVEL.instantiate()
	
	current_loaded_level.dimensions = level_size
	current_loaded_level.start = Vector2i.ZERO
	current_loaded_level.critical_path_length = cp_length
	current_loaded_level.branches = branches
	current_loaded_level.branch_length = branch_length
	
	GameState.register_level(current_loaded_level)
	add_child(current_loaded_level)
	
	GameState.run_time_from_start = Time.get_ticks_msec() ## Reset the current start timer
	GameState.number_of_kills = 0 ## Reset the kill count	

## Function to restart the Level
func on_level_restarted() -> void:	
	## Just load the level again passing the current level (restarting THIS level)
	load_level()
	
## Function to restart the Level hajrder
func on_level_harder_restarted(level_size: Vector2i = DEFAULT_SIZE, cp_length: int = DEFAULT_CRITICAL_LENGTH, branches: int = DEFAULT_BRANCHES, branch_length: Vector2i = DEFAULT_BRANCHES_SIZE) -> void:	
	## Just load the level again passing the current level (restarting THIS level)
	load_level(level_size, cp_length, branches, branch_length)
