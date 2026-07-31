class_name BaseRoom
extends Node3D

## This class is a BaseRoom from which all other rooms inherit.
##
## The main goal of this script is to fill the ceilings at runtime, making use of the [b]Ceilings[/b] to paint
## ceiling tiles where a ceiling is missing.[br]
## Alghoritm:
## Whenever a tile in the FLOORS tile is NOT a WALL-OUTER [3], or WALL-CORNER [2] or WALL-SIDE [1], we know these do NOT have a ceiling; so
## For those tiles we put a Ceiling tile mesh.

@onready var ceilings: GridMap = %Ceilings
@onready var floors: GridMap = %Floors

## Enum for room kinds
enum RoomKind{START,END,CRITICALPATH,BRANCHROOM,BRANCHPATHEND}

## Var that hold the RoomKind, defaults to a start room
var kind : RoomKind = RoomKind.START

## Var that hold the RoomType, defaults to a 4 way room
var type : BaseProceduralLevel.RoomType = BaseProceduralLevel.RoomType.R10x10_4W

var cell_ids_with_no_ceiling := []

func _ready() -> void:
	fill_ceilings()
	
func fill_ceilings() -> void:
	# For each cell in the Floors, if the cell is one of the ones WITHOUT a ceiling...
	for cell_name : String in ["Ground", "Hole-Corner", "Hole-Side", "Hole-UTurn"]:
		## This cell in Floors needs a ceiling, so let's add this id to the list
		var cell_to_fill := floors.mesh_library.find_item_by_name(cell_name)
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
