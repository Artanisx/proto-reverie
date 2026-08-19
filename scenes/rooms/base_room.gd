class_name BaseRoom
extends Node3D

## This class is a BaseRoom from which all other rooms inherit.
##
## The main goal of this script is to fill the ceilings at runtime, making use of the [b]Ceilings[/b] to paint
## ceiling tiles where a ceiling is missing.[br]
## Alghoritm:
## Whenever a tile in the FLOORS tile is NOT a WALL-OUTER [3], or WALL-CORNER [2] or WALL-SIDE [1], we know these do NOT have a ceiling; so
## For those tiles we put a Ceiling tile mesh.

const DROPPED_KEY_PREFAB := preload("res://scenes/collectibles/dropped_key/dropped_key.tscn")

@export var key_color: Door.KeyColor = Door.KeyColor.None	## This sets wheter the room contains a key (which color) or not (None)

@onready var ceilings: GridMap = %Ceilings
@onready var floors: GridMap = %Floors
@onready var enemies: Node3D = %Enemies


var cell_ids_with_no_ceiling := []

func _ready() -> void:
	fill_ceilings()
	prep_enemies()
	
func fill_ceilings() -> void:
	# For each cell in the Floors, if the cell is one of the ones WITHOUT a ceiling...
	for cell_name : String in ["Ground", "Hole-Corner", "Hole-Side", "Hole-UTurn"]:
		## This cell in Floors needs a ceiling, so let's add this id to the list
		var cell_to_fill : int = floors.mesh_library.find_item_by_name(cell_name)
		cell_ids_with_no_ceiling.push_back(cell_to_fill)
		
	# Get an array of coordinates for cells that have been painted (i.e. contains something)	
	var used_cells : Array[Vector3i]  = floors.get_used_cells()
	
	# Now we loop into those used_cells in order to check if it's a cell that requires a ceiling
	for cell_coords in used_cells:
		var tile_id: int = floors.get_cell_item(cell_coords)
		
		## If in the list of cell ids that require a ceiling, there's a cell that has been painted
		if cell_ids_with_no_ceiling.has(tile_id):
			## this means it needs to have a ceiling.
			## Paint said cell in the ceilings grid map, at the these coordinate, with the ceiling tile (id 0)
			ceilings.set_cell_item(cell_coords, 0)			

## This will listen to the screamed signal emitted by enemies
func prep_enemies() -> void:
	for enemy: Enemy in enemies.get_children():
		enemy.screamed.connect(on_scream_heard)
		## connect to the enemy.dead signal
		enemy.dead.connect(on_enemy_death)

## Each enemy will be warned (aggro)
## Basically if one enemy emits the screamed signal, this will be heard and all enemies will aggro the player
func on_scream_heard() -> void:
	for enemy: Enemy in enemies.get_children():
		## This enemy should register the player so he's aware of them
		enemy.player = GameState.current_player
		
## When an enemy dies, check if it's the last one in order to drop a key if this is a room key
func on_enemy_death(enemy_transform: Transform3D) -> void:
	for enemy: Enemy in enemies.get_children():
		if not enemy.health.is_dead():
			return	## There's at least one enemy alive in this room, so no key drop
	
	## If we're here and haven't returned, all enemies in the room are dead
	drop_key(enemy_transform)	## Drop the related key in the last enemy transform position that emitted this signal

## Drop the correct key in the passed position [br]
## Takes the Transform3D position for the key to spawn.
func drop_key(key_transform: Transform3D) -> void:
	var key : DroppedKey = DROPPED_KEY_PREFAB.instantiate() as DroppedKey
	key.color = key_color
	key.global_transform = key_transform
	GameState.current_level.add_child(key)
	
	## make the key pop up with an effect
	var rand_angle := randf_range(0, PI)	## pick a random angle 0-360°
	var launch_velocity : Vector3 = Vector3(cos(rand_angle) * 2.0, 5.0, sin(rand_angle) * 2.0) ## set a random velocity x, y=5.0, z
	key.apply_central_impulse(launch_velocity) ## Apply the calculated impulse
	
