class_name BaseProceduralLevel
extends BaseLevel

## This class extends BaseLevel, but rather than being hand made, it is procedurally generated.
##
## The main goal of this script is to procedurally generate the rooms (picking the ones in the list) laying them up.
## Being a subclass of Base Level it inhertis the logic for player spawning.
## The logic that actually PLACES rooms in the level, and the logic that selects WHICH ROOM to place depending on the adjacents room (if any) is still to be created.
## For now this script generates a 2D array, and in the position of each of the rooms it only puts a C if it's a room in the critical path or a number to define the branches. 
## So, the logic to choose which room to place (depending on which rooms is connected and where) and the logic to actually place the rooms in the level is to be created. 

## Dictionary for room prefabs
const ROOMS_MAP := {
	RoomType.R10x10_1W_BOTTOM: preload("res://scenes/rooms/10x_10_1_way_room_bottom.tscn"), #1 door (down)
	RoomType.R10x10_1W_LEFT: preload("res://scenes/rooms/10x_10_1_way_room_left.tscn"), #1 door (left)
	RoomType.R10x10_1W_RIGHT: preload("res://scenes/rooms/10x_10_1_way_room_right.tscn"), #1 door (right)
	RoomType.R10x10_1W_TOP: preload("res://scenes/rooms/10x_10_1_way_room_top.tscn"), #1 door (up)
	RoomType.R10x10_2W_BOTTOM_LEFT: preload("res://scenes/rooms/10x_10_2_way_room_bottom_left.tscn"), #2 doors (left, down)
	RoomType.R10x10_2W_BOTTOM_RIGHT: preload("res://scenes/rooms/10x_10_2_way_room_bottom_right.tscn"), #2 doors (right, down)
	RoomType.R10x10_2W_HORIZZONTAL: preload("res://scenes/rooms/10x_10_2_way_room_horizzontal.tscn"), #2 doors (right, left)
	RoomType.R10x10_2W_TOP_LEFT: preload("res://scenes/rooms/10x_10_2_way_room_top_left.tscn"), #2 doors (up, left)
	RoomType.R10x10_2W_TOP_RIGHT: preload("res://scenes/rooms/10x_10_2_way_room_top_right.tscn"), #2 doors (up, right)
	RoomType.R10x10_2W_VERTICAL: preload("res://scenes/rooms/10x_10_2_way_room_vertical.tscn"), #2 doors (up, down)
	RoomType.R10x10_3W_BOTTOM: preload("res://scenes/rooms/10x_10_3_way_room_bottom.tscn"), #3 doors (down, left, right)
	RoomType.R10x10_3W_LEFT: preload("res://scenes/rooms/10x_10_3_way_room_left.tscn"), #3 doors (up, down, left)
	RoomType.R10x10_3W_RIGHT: preload("res://scenes/rooms/10x_10_3_way_room_right.tscn"), #3 doors (up, down, right)
	RoomType.R10x10_3W_TOP: preload("res://scenes/rooms/10x_10_3_way_room_top.tscn"), #3 doors (up, left, right)
	RoomType.R10x10_4W: preload("res://scenes/rooms/10x_10_4_way_room.tscn") # 4 doors (down, left, right, up)
} 

## Some const for pickable items
const PICKABLE_ITEM_PREFAB = preload("res://scenes/equipment/pickable_item.tscn")
const PICKABLE_HEALTH_PACK_PREFAB = preload("res://scenes/collectibles/health_pack/pickable_health_pack.tscn")
const PICKABLE_EXP_COIN_PREFAB = preload("res://scenes/collectibles/exp_coin/pickable_exp_coin.tscn")
const GOBLIN_PREFAB = preload("res://scenes/characters/enemies/goblin.tscn")
const WEAPON_SWORD_DATA = preload("res://data/weapons/shortsword.tres")

## Constants for pickable stats
const BIG_HEALTH_PACK: int = 50
const MED_HEALTH_PACK: int = 25
const SMALL_HEALTH_PACK: int = 10
const BIG_EXP_COIN: int = 15
const MED_EXP_COIN: int = 5
const SMALL_EXP_COIN: int = 2

## Constants for random gen
const REGULAR_ROOM_HEALTHPACK_CHANCE: int = 25
const REGULAR_ROOM_MIN_ENEMIES: int = 1
const REGULAR_ROOM_MAX_ENEMIES: int = 3
const REGULAR_ROOM_MIN_COINS: int = 1
const REGULAR_ROOM_MAX_COINS: int = 7
const BRANCH_ROOM_HEALTHPACK_CHANCE: int = 30


const MINIMAP_ICONS_HEIGHT : float = 3.5 ## Y position for minimap icons

## Enum for room types
enum RoomType{R10x10_1W_BOTTOM, R10x10_1W_LEFT, R10x10_1W_RIGHT, R10x10_1W_TOP,
			  R10x10_2W_BOTTOM_LEFT, R10x10_2W_BOTTOM_RIGHT, R10x10_2W_HORIZZONTAL, R10x10_2W_TOP_LEFT, R10x10_2W_TOP_RIGHT, R10x10_2W_VERTICAL,
			  R10x10_3W_BOTTOM, R10x10_3W_LEFT, R10x10_3W_RIGHT, R10x10_3W_TOP,
			  R10x10_4W}
			
@export var dimensions: Vector2i = Vector2i(7,5) ## Defines the size of the level
@export var start: Vector2i = Vector2i(-1,-1) ## Defines where in the grid the starting room will be placed. If not defined (or it is invalid), a random place will be picked.
@export var critical_path_length: int = 13 ## Defines the shortest possible path from the start to the end room
@export var branches: int = 3 # How many detours there should be
@export var branch_length: Vector2i = Vector2i(1,4) # How long a detour is (from minimum to maximum rooms)
@export var room_size: int = 21 # The size of the room, including the portion related to the doors for proper placement.
@export var rng_seed: int = -1 ## Seed for procedural generation. Use -1 for random seed.

const DEBUG_SEED: int = 205585640 ## WARNING: PRECISE SEED FOR DEBUG!
const DEBUG_MODE: bool = true				## WARNING: IF SET TO TRUE, THINGS LIKE DEBUG_SEED WILL BE USED

@onready var rooms_container: Node3D = $Rooms

var room_map : Array ## 2D array of RoomData, mirroring the level grid structure
var branch_candidates : Array[Vector2i] ## List of room that can have branches added to them, so which rooms can support these detours
var rng: RandomNumberGenerator ## Random number generator for seeded generation

func _ready() -> void:
	initialize_level()
	place_entrance()
	generate_path(start, critical_path_length, "CP") # CP stands for CRITICAL PATH
	generate_branches()	
	
	reverse_print_level()
	
	## Actual room placement
	calculate_room_positions() 	
	
	reverse_print_level_grid()	
	reverse_print_level_map()
	
	generate_level()	
	check_generated_level()		## Fixes doors if they go towards a special room that is closed that way
	
	print_rooms()
	
	print("Seed used: " + str(get_used_seed()))
			
	## Finally call the super (baselevel) _ready function to initialize the player
	super()
	
## This function will procedurally generate the level assembling rooms
func initialize_level() -> void:
	## WARNING: DEBUG MODE
	if DEBUG_MODE:
		print_rich("[color=yellow][b]WARNING:[/b] base_procedural_level.gd DEBUG MODE is [b]ON[/b][/color]")
		rng_seed = DEBUG_SEED
	
	## Initialize the random number generator
	rng = RandomNumberGenerator.new()
	if rng_seed != -1: ## -1 stands for random seed
		rng.seed = rng_seed
	else:
		rng.seed = randi() ## Randomize a seed using randi() that returns a smaller value that can be properly seen in the inspector
##		rng.randomize()

	## ## Initialize the room_map array
	for x in dimensions.x:
		room_map.append([])	# First we add empty arrays to form the columns of the map
		for y in dimensions.y:
			## Create a RoomData with default values
			var empty_room := RoomData.new("", Vector2i.ZERO, null)
			room_map[x].append(empty_room)

	## With Dimension X = 7 and Y = 5, at this point we have a 2d array with 7 columns and 5 rows, all filled with " "
	## [ ][ ][ ][ ][ ][ ][ ]
	## [ ][ ][ ][ ][ ][ ][ ]
	## [ ][ ][ ][ ][ ][ ][ ]
	## [ ][ ][ ][ ][ ][ ][ ]
	## [ ][ ][ ][ ][ ][ ][ ]

## This function will print the dungeon, so we can see what's been generated. Meant for debugging.
func print_level() -> void:
	var level_as_string : String = ""
	
	## We count from top row and counting down to 0. Hence we start by y - 1 (array start at zero) and count -1, -1 to reach the top. We read from top to bottom.
	for y in range (dimensions.y - 1, -1, -1):
		for x in dimensions.x:
			if room_map[x][y].room_identifier != "":	 ## if there's a room
				level_as_string += "[" + room_map[x][y].room_identifier + "]"	
			else:
				level_as_string += "[     ]"	## this is empty, there's no room		
			
		level_as_string += '\n'
	
	print(level_as_string)
	
## This function will print the dungeon, but with the identifier we also print the x,y coordinates of the map
func print_level_map() -> void:
	var level_as_string : String = ""
	
	## We count from top row and counting down to 0. Hence we start by y - 1 (array start at zero) and count -1, -1 to reach the top. We read from top to bottom.
	for y in range (dimensions.y - 1, -1, -1):
		for x in dimensions.x:
			if room_map[x][y].room_identifier != "":	 ## if there's a room
				level_as_string += "[" + room_map[x][y].room_identifier + "](" + str(x) + "," + str(y) + ")"
			else:
				level_as_string += "["+ str(x) + "," + str(y) +"]"	## this is empty, there's no room		
			
		level_as_string += '\n'
	
	print(level_as_string)

## This function will print the level grid, which contains rooms positions Meant for debugging.
func print_level_grid() -> void:
	var level_as_string : String = ""
	
	## We count from top row and counting down to 0. Hence we start by y - 1 (array start at zero) and count -1, -1 to reach the top. We read from top to bottom.
	for y in range (dimensions.y - 1, -1, -1):
		for x in dimensions.x:			
			level_as_string += "[" + str(room_map[x][y].world_position) + "]"			
		level_as_string += '\n'
	
	print(level_as_string)
	
## This function will place the first room, where the player will spawn
func place_entrance() -> void:	
	### Check if the start position is valid.
	if start.x < 0 or start.x >= dimensions.x:
		start.x = rng.randi_range(0, dimensions.x - 1)
	if start.y < 0 or start.y >= dimensions.y:
		start.y = rng.randi_range(0, dimensions.y - 1)
		
	## Update the room_map with the start room identifier
	room_map[start.x][start.y].room_identifier = "START"
	
## This function will generate the critical path. 
## This is a iterative process, adding one room at time, starting from the entrance.
## It takes two arguments:[br]
## from: an integer that defines from which point we are in the path[br]
## length: the max critical_path_length we allow	
## marker: this will be the value the room will be set
func generate_path(from: Vector2i, length: int, marker : String) -> bool:
	if length == 0:		
		return true ## We generated the whole path, so we can return
		## This will return something like this
		## [0][7][6][3][2][1][0]
		## [0][8][5][4][0][0][0]
		## [10][9][0][0][0][0][0]
		## [11][12][0][0][0][0][0]
		## [S][13][0][0][0][0][0]
		## Starting from S (starting room) and counting down from the max_critical_path to 0

		
	## Hold the current room
	var current : Vector2i = from
	
	## Hold the direction
	var direction : Vector2i
	
	## Pick a random direction
	match rng.randi_range(0, 3):
		0: 
			direction = Vector2i.UP
		1:
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.DOWN
		3:
			direction = Vector2i.LEFT
	
	## We loop 4 times for 4 possible directions
	for i in 4:	
		## Go in this new random direction and check if these new coordinates are valid
		if (current.x + direction.x >= 0 and current.x + direction.x < dimensions.x and
			current.y + direction.y >= 0 and current.y + direction.y < dimensions.y and 
			room_map[current.x + direction.x][current.y + direction.y].room_identifier == ""):	## The value in these new coordinates must also be empty and not already contain a room
			current += direction	## This is all valid, so we can set this current position and proceed in this direction. Meaning, this is valid as the critical path			
			
			if length == 1 and marker == "CP":	
				## this is the last room of the critical path, so rather than marker, i want to put  ENDRO as end end room.
				room_map[current.x][current.y].room_identifier = "ENDRO"
			elif length == 1 and marker.contains("B"):
				## this is the last room of a branch, we want to mark it as such
				## first we store which branch this is:
				var room_name: String = marker ## B1ML2L:1
				var parts := room_name.split("M") ## B1 - L2L:1
				var branch_name : int = int(parts[0])	 ## 1
				var parts2 := parts[1].split(":") ## L2L -  1  
				var branch_length_str := int(parts2[0])  ## 2
				room_map[current.x][current.y].room_identifier = "ENDBR" + str(branch_name) + "L:" + str(branch_length_str) ##ENBDBR1L:2
			else:
				## we mark this as the value passed as marker. If this is being called from the generation of the critical path, it will be a 'C', if not will be a number for the branches >>> NOT ANMIORE:We change the value of this position in the array to something different than 0; the lenght of the critical path. Basically we are adding a room here (for now it's an umber and it is the number of rooms towards the exit)
				room_map[current.x][current.y].room_identifier = marker + "L:" + str(length) # I need to see the distance in the map
				
			## we don't want to create detours from the alst room or the start room, so lenght should be more than 1 and less than critical_path_legnth
			if length > 1 and length < critical_path_length:
				branch_candidates.append(current) ## We add this position in the map in the list of the branch_candidates, so room that can go somewhere else in a detour. This can only happen if we're not in the last room before the end (so lenght must be  > 1)
			
			if generate_path(current, length - 1, marker): ## We reduce the length of the critical path by 1 - starting from current - and call this again.				
				return true # it returned true, so we generated the whole thing, and the critical path is complete
			else:
				# it returned false, the critical path failed at some point. 
				branch_candidates.erase(current) ## since this is not valid, we remove it as a possible branch candidate from its list
				# We need to reverse the change we made and return back as it wasn't the right way to go
				room_map[current.x][current.y].room_identifier = "" ## set this room back to zero (empty)
				current -= direction #go back 
		## We need to rotate the direction and tyr again!
		direction = Vector2i(direction.y, -direction.x)				
	return false # We couldn't find a valid room, so we return false in order for the alghoritm to try a different direction	

## This function will generate branches (detours) from the list of potential branch candidate rooms (so rooms in the critical path that can be the start point of a detour
func generate_branches() -> void:
	var branches_created : int = 0 # hold the number of branches created thus far
	var candidate : Vector2i	 # room we are branching out from
	
	# while there are still more branches to be created (branches variable being the setting)
	while branches_created < branches and branch_candidates.size(): ## also check there are still branch_candidates, to prevent infinite loop
		# select a branch candidate at random from the list
		candidate = branch_candidates[rng.randi_range(0, branch_candidates.size() -1)]
		# generate a new path from this candidate of the branch_length we set. the marker branches created plus 1 (so each branch will be 1,1,1 or 2,2,2 etc)
		## first, we define a random lenght for this branch based upon settings
		var b_length : int = rng.randi_range(branch_length.x, branch_length.y)
		if generate_path(candidate, b_length, "B" + str(branches_created + 1) + "ML" + str(b_length)): 	## BXMLY where X is branch number and Y is max length
			branches_created += 1 #success
		else:
			branch_candidates.erase(candidate) #failure, remove this	

## This function will generate the whole level
func generate_level() -> void:
	var is_there_room_up: bool = false
	var is_there_room_down: bool = false
	var is_there_room_left: bool = false
	var is_there_room_right: bool = false
	
	### IMPORTANT!! REMEMEBR THESE ARE THE COORDINATES
	## POSTIIVE Z  TOP  (equivale a positive Y)
	## NEGATIVE Z  DOWN (equivale a negative y)	
	## POSTIIVE X LEFT
	## NEGATIVE X RIGHT	
	##     z+
	## x+       x-
	##     z-			

	
	for i in range(dimensions.x):
		for j in range(dimensions.y):  
			## First we check if there's a room (check room_identifier instead of level[i][j])
			if room_map[i][j].room_identifier != "":
				## Store the kind of room it is for proper assignment
				var kind : BaseRoom.RoomKind
				
				if room_map[i][j].room_identifier == "START":
					kind = BaseRoom.RoomKind.START
				elif room_map[i][j].room_identifier == "ENDRO":
					kind = BaseRoom.RoomKind.END
				elif room_map[i][j].room_identifier.contains("ENDBR"):
					kind = BaseRoom.RoomKind.BRANCHPATHEND 
				elif room_map[i][j].room_identifier.contains("CP"):
					kind = BaseRoom.RoomKind.CRITICALPATH
				else:
					kind = BaseRoom.RoomKind.BRANCHROOM
				
				## Reset flags
				is_there_room_up = false
				is_there_room_down = false
				is_there_room_left = false
				is_there_room_right = false
				
				## CHECK if it's a START room
				if (kind == BaseRoom.RoomKind.START):
					## Check if there's a room UP/DOWN/RIGHT/LEFT that is the highest CP
					if j-1 >= 0 and room_map[i][j-1].room_identifier != "" and room_map[i][j-1].room_identifier.contains("CP") and calculate_cp_length(room_map[i][j-1].room_identifier) == critical_path_length:
						is_there_room_down = true
					if j+1 < dimensions.y and room_map[i][j+1].room_identifier != "" and room_map[i][j+1].room_identifier.contains("CP") and calculate_cp_length(room_map[i][j+1].room_identifier) == critical_path_length:
						is_there_room_up = true
					if i-1 >= 0 and room_map[i-1][j].room_identifier != "" and room_map[i-1][j].room_identifier.contains("CP") and calculate_cp_length(room_map[i-1][j].room_identifier) == critical_path_length:
						is_there_room_right = true
					if i+1 < dimensions.x and room_map[i+1][j].room_identifier != "" and room_map[i+1][j].room_identifier.contains("CP") and calculate_cp_length(room_map[i+1][j].room_identifier) == critical_path_length:
						is_there_room_left = true
				
				## CHECK if it's a END room
				elif (kind == BaseRoom.RoomKind.END):
					if j-1 >= 0 and room_map[i][j-1].room_identifier != "" and room_map[i][j-1].room_identifier.contains("CP") and calculate_cp_length(room_map[i][j-1].room_identifier) == 2:
						is_there_room_down = true
					if j+1 < dimensions.y and room_map[i][j+1].room_identifier != "" and room_map[i][j+1].room_identifier.contains("CP") and calculate_cp_length(room_map[i][j+1].room_identifier) == 2:
						is_there_room_up = true
					if i-1 >= 0 and room_map[i-1][j].room_identifier != "" and room_map[i-1][j].room_identifier.contains("CP") and calculate_cp_length(room_map[i-1][j].room_identifier) == 2:
						is_there_room_right = true
					if i+1 < dimensions.x and room_map[i+1][j].room_identifier != "" and room_map[i+1][j].room_identifier.contains("CP") and calculate_cp_length(room_map[i+1][j].room_identifier) == 2:
						is_there_room_left = true
				
				## CHECK if it's a BRANCHPATHEND room
				elif (kind == BaseRoom.RoomKind.BRANCHPATHEND):
					var branch_room_name : String = room_map[i][j].room_identifier ## ENDBR1L:3
					var parts := branch_room_name.split(":") ## ENDBR1L   -    3
					var branch_num_name := parts[0].split("R")[1].split("L")[0]	## 1
					
					if j-1 >= 0 and room_map[i][j-1].room_identifier != "" and room_map[i][j-1].room_identifier.contains("B") and calculate_branch_length(branch_num_name, room_map[i][j-1].room_identifier) == 2:
						is_there_room_down = true
						##print("For this BRANCHPATENDROOM: " + str(room_map[i][j].room_identifier) + "We are saying is_there_room_down = true")
					if j+1 < dimensions.y and room_map[i][j+1].room_identifier != "" and room_map[i][j+1].room_identifier.contains("B") and calculate_branch_length(branch_num_name, room_map[i][j+1].room_identifier) == 2:
						is_there_room_up = true						
					if i-1 >= 0 and room_map[i-1][j].room_identifier != "" and room_map[i-1][j].room_identifier.contains("B") and calculate_branch_length(branch_num_name, room_map[i-1][j].room_identifier) == 2:
						is_there_room_right = true						
					if i+1 < dimensions.x and room_map[i+1][j].room_identifier != "" and room_map[i+1][j].room_identifier.contains("B") and calculate_branch_length(branch_num_name, room_map[i+1][j].room_identifier) == 2:
						is_there_room_left = true						
					
					## Check if no neighboors branchroom of length 2 have been detected
					if not is_there_room_down and not is_there_room_up and not is_there_room_right and not is_there_room_left:
						## There are no branchrooms (-1) nearby so this is a Branch of length 1
						var length_A : int = 0
						var length_B : int = 0
						var length_C : int = 0
						var length_D : int = 0						
						
						## Here we have to check for all neighbhoors the one with the highest CP as that will be the one connected
						## High CP will have the entrance to the BRANCHENED room and the next CP
						## We calculate each neighboors CP number
						if j-1 >= 0 and room_map[i][j-1].room_identifier != "" and room_map[i][j-1].room_identifier.contains("CP"):
							length_A = calculate_cp_length(room_map[i][j-1].room_identifier)							
						if j+1 < dimensions.y and room_map[i][j+1].room_identifier != "" and room_map[i][j+1].room_identifier.contains("CP"):
							length_B = calculate_cp_length(room_map[i][j+1].room_identifier)							
						if i-1 >= 0 and room_map[i-1][j].room_identifier != "" and room_map[i-1][j].room_identifier.contains("CP"):
							length_C = calculate_cp_length(room_map[i-1][j].room_identifier)							
						if i+1 < dimensions.x and room_map[i+1][j].room_identifier != "" and room_map[i+1][j].room_identifier.contains("CP"):
							length_D = calculate_cp_length(room_map[i+1][j].room_identifier)
						
						## Only the biggest CP enters the branchendroom (i.e. if there's CPL:9 and CPL:8, only CPL:9 will have its room direction set to true
						if length_A > length_B and 	length_A > length_C and length_A > length_D:
							is_there_room_down = true
						elif length_B > length_A and 	length_B > length_C and length_B > length_D:
							is_there_room_up = true
						elif length_C > length_A and 	length_C > length_B and length_C > length_D:
							is_there_room_right = true
						elif length_D > length_A and 	length_D > length_B and length_D > length_C:
							is_there_room_left = true						
						
						if not is_there_room_down and not is_there_room_up and not is_there_room_right and not is_there_room_left:
							printerr("generate_level(372): Despite checks, there's still a BranchEndPathRoom with no connections. This should NOT happen.")
				else:
					## Regular room logic - check all adjacent rooms
					if j-1 >= 0 and room_map[i][j-1].room_identifier != "":
						is_there_room_down = true	
					if j+1 < dimensions.y and room_map[i][j+1].room_identifier != "":
						is_there_room_up = true
					if i-1 >= 0 and room_map[i-1][j].room_identifier != "":
						is_there_room_right = true
					if i+1 < dimensions.x and room_map[i+1][j].room_identifier != "":
						is_there_room_left = true
				
					
				#print("I'm checking room name " + str(level[i][j]) + " that is i:" + str(i) + " j:" + str(j) + " in pos: " + str(level_grid[i][j]) + 
				#	  " and here's the deal. room_up:" + str(is_there_room_up) + " room_down: " + str(is_there_room_down) + " room_right: " + str(is_there_room_right) + "room_left: " + str(is_there_room_left))	
					
				if is_there_room_up and is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_4W, kind)
				#	print("Placing a RoomType.R10x10_4W in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and is_there_room_down and not is_there_room_right and not is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_2W_VERTICAL, kind)
				#	print("Placing a RoomType.R10x10_2W_VERTICAL in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and not is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_2W_HORIZZONTAL, kind)
				#	print("Placing a RoomType.R10x10_2W_HORIZZONTAL in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and not is_there_room_right and not is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_1W_BOTTOM, kind)
				#	print("Placing a RoomType.R10x10_1W_TOP in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and not is_there_room_right and not is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_1W_TOP, kind)
				#	print("Placing a RoomType.R10x10_1W_BOTTOM in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and not is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_1W_RIGHT, kind)
				#	print("Placing a RoomType.R10x10_1W_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and not is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_1W_LEFT, kind)
				#	print("Placing a RoomType.R10x10_1W_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_2W_TOP_RIGHT, kind)
				#	print("Placing a RoomType.R10x10_2W_BOTTOM_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_2W_TOP_LEFT, kind)
				#	print("Placing a RoomType.R10x10_2W_BOTTOM_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_2W_BOTTOM_RIGHT, kind)
				#	print("Placing a RoomType.R10x10_2W_TOP_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_2W_BOTTOM_LEFT, kind)
				#	print("Placing a RoomType.R10x10_2W_TOP_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_3W_TOP, kind)
				#	print("Placing a RoomType.R10x10_3W_BOTTOM in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_3W_LEFT, kind)
				#	print("Placing a RoomType.R10x10_3W_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_3W_RIGHT, kind)
				#	print("Placing a RoomType.R10x10_3W_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(room_map[i][j].world_position, RoomType.R10x10_3W_BOTTOM, kind)
				#	print("Placing a RoomType.R10x10_3W_TOP in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))				
				else:
					## This should not happen right?
					printerr("generate_level() #402: Not placed a room for: " + str(room_map[i][j].room_identifier))
				
				## Resets flags for the next run
				is_there_room_up = false
				is_there_room_down = false
				is_there_room_left = false
				is_there_room_right = false	
			
				## AFTER placing the room, store the reference in room_map
				## We need to find the room we just placed
				for child in rooms_container.get_children():
					if child is BaseRoom and child.position.x == room_map[i][j].world_position.x and child.position.z == room_map[i][j].world_position.y:
						room_map[i][j].room_instance = child
						
						if room_map[i][j].room_instance == null:
							printerr("generate_level() #450: Room Instance NULL for " + str(room_map[i][j].room_identifier))
						
						break	
		

## This function will actually place a room in the level
func place_room(room_position: Vector2i, type: RoomType = RoomType.R10x10_4W, kind: BaseRoom.RoomKind = BaseRoom.RoomKind.START) -> BaseRoom:
	## To start, we'll place R10x10_4W	
	var room : BaseRoom = ROOMS_MAP[type].instantiate()
	
	## Position the new room in the given coordinates
	room.position = Vector3(room_position.x, 0, room_position.y)	
	
	## Define its kind
	room.kind = kind
	
	## Define its type
	room.type = type
		
	## The room is ready to be added to the rooms container so	
	## Add it to the rooms container as a child
	rooms_container.add_child(room)
	
	## Place additional nodes depending on its kind
	## Needs to happen after the room is in the tree, or won't physically exists
	place_room_nodes(room)
	
	#print("I Have placed a room of kind: " + str(room.kind) + ", in position:" + str(room.position))
	
	## Return the room so we can store it in room_map
	return room
	
## This function calculates the actual position in the level for the room.
## Puts the postiions in the level_grid array
func calculate_room_positions() -> void:	
	## Update the world positions in room_map
	for x in dimensions.x:
		for y in dimensions.y:
			room_map[x][y].world_position = Vector2i(x * room_size, y * room_size)

## This function will print the rooms, so we can see what's been generated. Meant for debugging.
func print_rooms() -> void:
	var room_as_string : String = ""
	
	for x in dimensions.x:
		for y in dimensions.y:
			var room : BaseRoom = room_map[x][y].room_instance
			if room != null:
				var kind_as_string : String = ""
				
				match(room.kind):
					0: kind_as_string = "START"
					1: kind_as_string = "END"
					2: kind_as_string = "CRITICALPATH"
					3: kind_as_string = "BRANCHROOM"
					4: kind_as_string = "BRANCHPATHEND"
				
				room_as_string += "[" + kind_as_string + "](" + str(room.position.x) + "," + str(room.position.z) + ")"
	
	print(room_as_string)

func calculate_cp_length(level_to_calculate: String) -> int:
	return int(level_to_calculate)
	
func calculate_branch_length(branch_number_name: String, level_to_calculate: String) -> int:
	## Branch rooms have this nomenclature: [BXMLYL:Z]
	## Where X is the branch name in numerical form
	## Y is the max branch length
	## Z is current length
	
	## Before we return the length to allow calculation to see if the adhjacnet room is right, we need to check if it's on the same branch:
	if is_this_same_branch(branch_number_name, level_to_calculate):
		#it is, so we can return the number of length	
		var parts := level_to_calculate.split(":")
		#print("So, this length is: " + parts[1])
		return int(parts[1])
	else:
		# it isn't, we should return a very high number that will surely fail
		#print("No, this isn't on the same branch, set length to 999 to make this fail")
		return 999
	
func is_this_same_branch(branch_number_name: String, room_to_check : String) -> bool:
	## this receives a branch_nuber_name [K] and a room name [BXMLYL:Z]
	## returns true if the room to check belongs to the same branch, so only if K == X
	
	## however, we need to check for ENDBRXL:Y too because a endbranchroom might be adjacent
	## we need to instantly return false in this case
	if room_to_check.contains("ENDBR"):
		#print("checking for another branch end, we should return false here")
		return false
	
	var room_belongs_to_branch := room_to_check.split("M")[0][1] ## X
	#print("Checking if this is the same branch! So, branch number name is: " + branch_number_name + " and i'm checking for room: " + room_to_check + "! I think rooms_benlongs_to_bracnh is " + room_belongs_to_branch + " therefore I belive this should be: ")
	
	
	if branch_number_name == room_belongs_to_branch:
		#print("TRUE!")	
		return true
	else:
		#print("FALSE!")	
		return false

## This function checks if the passed room in an ender room like START/ENDROOM/ENDBRANCH		
func is_endpath_room(room_to_check: String) -> bool:	
	if room_to_check.contains("START") or room_to_check.contains("ENDRO") or room_to_check.contains("ENDBR"): 
		return true
	else:
		return false

## This function places extra nodes depending on the room kind
## For example, for a End Room it places a blue light and a blue minimap_icon
## Can be used to spawn enemies, items, props...
## For now it supports END, START and BRANCHPATHEND
## It can easily include a place_room_nodes_regular_room() to populate regular rooms in a separate function.
func place_room_nodes(room_to_place: BaseRoom) -> void:
	var kind : BaseRoom.RoomKind = room_to_place.kind
	var room : BaseRoom = room_to_place
	
	## If it's a branche room, shoudl be more difficult, more enemies because it leads to goodies
	## low chance to have a health pack, with med health
	## always have 3 enemies (or as many spawners there are... for now 3)
	if kind == BaseRoom.RoomKind.BRANCHROOM:
		## HEALTH PACK:
		var hp_chance = randi_range(0, 100)
		if hp_chance < BRANCH_ROOM_HEALTHPACK_CHANCE:
			## Lucky! Spawn a low health pack
			for child in room.pickables.get_children():
				if child is HealthPackSpawn:
					child.set_healthpack(PICKABLE_HEALTH_PACK_PREFAB, 8.0, Pickable.Direction.Y_AXIS, MED_HEALTH_PACK)
					print("Lucky! Med HealthPack placed in a branch room.")
					
		## ENEMIES
		for child in room.enemies.get_children():
			if child is EnemySpawn:
				child.set_enemy(GOBLIN_PREFAB, 2.5, 2000, 2.0, 10, 8)
				print("Branch Room: Placed an enemy.")
	
	## If it's a REGULAR ROOM
	## low chance to have a health pack, with low health
	## can have 1-3 enemies
	## can have 1-7 coins, with low experience 
	if kind == BaseRoom.RoomKind.CRITICALPATH:
		
		## HEALTH PACK:
		var hp_chance = randi_range(0, 100)
		if hp_chance < REGULAR_ROOM_HEALTHPACK_CHANCE:
			## Lucky! Spawn a low health pack			
			for child in room.pickables.get_children():
				if child is HealthPackSpawn:
					child.set_healthpack(PICKABLE_HEALTH_PACK_PREFAB, 8.0, Pickable.Direction.Y_AXIS, SMALL_HEALTH_PACK)
					print("Lucky! Small HealthPack placed in a regular room.")
		
		## ENEMIES			
		var num_enemies_to_spawn = randi_range(REGULAR_ROOM_MIN_ENEMIES, REGULAR_ROOM_MAX_ENEMIES)
				
		var enemyspawners : Array[EnemySpawn]		
		
		## Populate the array of enemy spawners
		for child in room.enemies.get_children():
			if child is EnemySpawn:
				enemyspawners.append(child)
		
		## Spawn the required number of enemies
		while (num_enemies_to_spawn > 0):		
			var selected_spawner = enemyspawners.pick_random()
					
			## Spawn an enemy
			selected_spawner.set_enemy(GOBLIN_PREFAB, 2.5, 2000, 2.0, 10, 8)				
			print("Enemy placed in a regular room.")
			
			##Remove th spawner from the array
			enemyspawners.erase(selected_spawner)
			
			## reduce the counter
			num_enemies_to_spawn -= 1
			
		## COINS			
		var num_coins_to_spawn = randi_range(REGULAR_ROOM_MIN_COINS, REGULAR_ROOM_MAX_COINS)
				
		var expcoinspawners : Array[ExpCoinSpawn]		
		
		## Populate the array of expcoinspawners
		for child in room.pickables.get_children():
			if child is ExpCoinSpawn:
				expcoinspawners.append(child)
		
		## Spawn the required number of coins
		while (num_coins_to_spawn > 0):		
			var selected_spawner = expcoinspawners.pick_random()
					
			## Spawn an coin			
			selected_spawner.set_expcoin(PICKABLE_EXP_COIN_PREFAB, 12.0, Pickable.Direction.Y_AXIS, SMALL_EXP_COIN)
			print("Lucky! Exp coin placed in a regular room.")
			
			##Remove th spawner from the array
			expcoinspawners.erase(selected_spawner)
			
			## reduce the counter
			num_coins_to_spawn -= 1
		
	
	## If it's an END ROOM let's add a blue omnilight3d
	if kind == BaseRoom.RoomKind.END:
		var light : OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.0, 0.0, 1.0)
		light.light_energy = 0.01
		light.light_size = 1.0
		light.position = Vector3.ZERO
		room.add_child(light)
		
		## Also create a Sprite3D for the minimap
		var minimap_icon : Sprite3D = Sprite3D.new()
		minimap_icon.texture = preload("res://assets/textures/player_minimap.png")
		minimap_icon.modulate = Color(0.0, 0.0, 1.0)
		minimap_icon.axis = Vector3.Axis.AXIS_Y
		minimap_icon.set_layer_mask_value(1, false) 
		minimap_icon.set_layer_mask_value(2, true)
		minimap_icon.position = Vector3(0.0, MINIMAP_ICONS_HEIGHT, 0.0) 
		minimap_icon.scale = Vector3(20.0, 20.0, 20.0)
		room.add_child(minimap_icon)	
		
		## End  Room should contian goodies:
		## Always 1 big health pack
		## FINAL BOSS : NYI		
		
		## BIG HEALTH PACK		
		for child in room.pickables.get_children():
			if child is HealthPackSpawn:
				child.set_healthpack(PICKABLE_HEALTH_PACK_PREFAB, 8.0, Pickable.Direction.Y_AXIS, BIG_HEALTH_PACK)
				print("Placed a HealthPack in the End Room")		
				
		## SPAWN AN ENEMY: TODO: SHOULD BE A BOSS		
		var enemyspawners : Array[EnemySpawn]		
		
		## Populate the array of enemy spawners
		for child in room.enemies.get_children():
			if child is EnemySpawn:
				enemyspawners.append(child)
		
		## Pick a random spawner for the boss
		var selected_spawner = enemyspawners.pick_random()
				
		## Spawn the "boss"		
		selected_spawner.set_enemy(GOBLIN_PREFAB, 1.5, 1000, 4.0, 100, 45)				
		print("END ROOM: Spawning an enemy, but we should spawn a proper BOSS!")

		
	## If it's an START ROOM let's add a green omnilight3d
	if kind == BaseRoom.RoomKind.START:
		var light : OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.0, 1.0, 0.0)
		light.light_energy = 0.01
		light.light_size = 1.0
		light.position = Vector3.ZERO
		room.add_child(light)
		
		## Also create a Sprite3D for the minimap
		var minimap_icon : Sprite3D = Sprite3D.new()
		minimap_icon.texture = preload("res://assets/textures/player_minimap.png")
		minimap_icon.modulate = Color(0.0, 1.0, 0.0, 0.25)
		minimap_icon.axis = Vector3.Axis.AXIS_Y
		minimap_icon.set_layer_mask_value(1, false) 
		minimap_icon.set_layer_mask_value(2, true)
		minimap_icon.position = Vector3(0.0, MINIMAP_ICONS_HEIGHT, 0.0) 
		minimap_icon.scale = Vector3(20.0, 20.0, 20.0)
		room.add_child(minimap_icon)
		
		## Since it's a start room, nothing should spawn!
		###DEBUG LET'S USE START ROOM
		## BIG HEALTH PACK
		#for child in room.pickables.get_children():
			#if child is HealthPackSpawn:
				#child.set_healthpack(PICKABLE_HEALTH_PACK_PREFAB, 8.0, Pickable.Direction.Y_AXIS, BIG_HEALTH_PACK)
				#print("BRANCHENDROOM: Placed a HealthPack in START ROOM FOR DEBUGGING PURPOSES")
				#
		#### BDEBUG IG EXP COINS	
		#for child in room.pickables.get_children():
			#if child is ExpCoinSpawn:
				#child.set_expcoin(PICKABLE_EXP_COIN_PREFAB, 12.0, Pickable.Direction.Y_AXIS, BIG_EXP_COIN)
				#print("BRANCHENDROOM: Placed a Exp Coin")
				#
		#### BDEBUG IG enemies	
		#for child in room.enemies.get_children():
			#if child is EnemySpawn:
				#child.set_enemy(GOBLIN_PREFAB, 2.5, 2000, 2.0, 10, 8)
				#print("BRANCHENDROOM: Placed an enemy!!!!!!")
		
		
	## If it's an BRANCH PATH END ROOM (whre a chest/boss may lie) let's add a red omnilight3d
	if kind == BaseRoom.RoomKind.BRANCHPATHEND:
		var light : OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.0, 0.0)
		light.light_energy = 0.01
		light.light_size = 1.0
		light.position = Vector3.ZERO
		room.add_child(light)
		
		## Also create a Sprite3D for the minimap
		var minimap_icon : Sprite3D = Sprite3D.new()
		minimap_icon.texture = preload("res://assets/textures/player_minimap.png")
		minimap_icon.modulate = Color(1.0, 0.0, 0.0, 0.25)
		minimap_icon.axis = Vector3.Axis.AXIS_Y
		minimap_icon.set_layer_mask_value(1, false) 
		minimap_icon.set_layer_mask_value(2, true)
		minimap_icon.position = Vector3(0.0, MINIMAP_ICONS_HEIGHT, 0.0) 
		minimap_icon.scale = Vector3(20.0, 20.0, 20.0)
		room.add_child(minimap_icon)
		
		## Branch Path End Room should contian goodies:
		## Always 1 big health pack
		## No enemies
		## Max (7) coins, each worth 15 exp to grant a full level
		
		## BIG HEALTH PACK		
		for child in room.pickables.get_children():
			if child is HealthPackSpawn:
				child.set_healthpack(PICKABLE_HEALTH_PACK_PREFAB, 8.0, Pickable.Direction.Y_AXIS, BIG_HEALTH_PACK)
				print("BRANCHENDROOM: Placed a HealthPack")
		
		## BIG EXP COINS	
		for child in room.pickables.get_children():
			if child is ExpCoinSpawn:
				child.set_expcoin(PICKABLE_EXP_COIN_PREFAB, 12.0, Pickable.Direction.Y_AXIS, BIG_EXP_COIN)
				print("BRANCHENDROOM: Placed a Exp Coin")

## This function checks the placed rooms to see if the doors are correct
func check_generated_level() -> void:
	## We need to iterate in the room_map 2D array that stores our generated level
	## We need to make sure that neighbor rooms to the special rooms (start, endro, endbr) that are 1 way
	## only have a door towards them if they are facing that open way.
	
	## First we iterate through the room_map
	for y in range (dimensions.y - 1, -1, -1):
		for x in dimensions.x:
			## We now check if the room is a special room
			#var room : RoomData = room_map[x][y]						## RoomData structure that holds all the info
			var room_instance : BaseRoom = room_map[x][y].room_instance ## BaseRoom instance that's instatiated
			if room_instance == null:	## no room here				
				continue				## next iteration
			var room_kind : BaseRoom.RoomKind = room_instance.kind ## i.e. BaseRoom.RoomKind.START
			var room_type : RoomType = room_instance.type		## i.e. RoomType.R10x10_1W_BOTTOM
			if room_kind == BaseRoom.RoomKind.START or room_kind == BaseRoom.RoomKind.END or room_kind == BaseRoom.RoomKind.BRANCHPATHEND:
				# Now we need to check the neighboors and work on them
				check_neighboors(x, y, room_type)

## This function takes:
# 1: The position X in the grid of the special room, so we can find the neighboors
# 2: The position Y in the grid of the special room, so we can find the neighboors
# 3: the room_type, meaning R10x10_1W_BOTTOM or similar, so we know which way they can have a room towards it
func check_neighboors(room_grid_pos_x : int, room_grid_pos_y: int, r_type: RoomType) -> void:
	## The Neighboors are:
	## [1][2][3]
	## [4][x,y][5]
	## [6][7][8]
	## We only care about 2 (x,y+1) ; 4 (x+1,y); 5(x-1, y); 7 (x,y-1)
	
	var neighboor_dict: Dictionary = { 2: Vector2i(room_grid_pos_x, room_grid_pos_y + 1),
									   4: Vector2i(room_grid_pos_x + 1, room_grid_pos_y),
									   5: Vector2i(room_grid_pos_x - 1, room_grid_pos_y),
									   7: Vector2i(room_grid_pos_x, room_grid_pos_y - 1)}
									
		
	## Calculate the door direction. It can only be one of these types	
	match(r_type):
		RoomType.R10x10_1W_BOTTOM:			
			## check_neighboor(neighboor_dict[2], up_forbidden, down_forbidden, left_forbidden, right_forbidden)
			# 7 CAN have door up
			check_neighboor(neighboor_dict[7], false, false, false, false)
			# 5 cannot have door left
			check_neighboor(neighboor_dict[5], false, false, true, false)
			# 4 cannot have door right
			check_neighboor(neighboor_dict[4], false, false, false, true)
			# 2 cannot have door down
			check_neighboor(neighboor_dict[2], false, true, false, false)
		RoomType.R10x10_1W_LEFT:			
			## check_neighboor(neighboor_dict[2], up_forbidden, down_forbidden, left_forbidden, right_forbidden)
			# 7 cannot have door up
			check_neighboor(neighboor_dict[7], true, false, false, false)
			# 5 cannot have door left
			check_neighboor(neighboor_dict[5], false, false, true, false)
			# 4 CAN have door right
			check_neighboor(neighboor_dict[4], false, false, false, false)
			# 2 cannot have door down
			check_neighboor(neighboor_dict[2], false, true, false, false)
		RoomType.R10x10_1W_RIGHT:			
			## check_neighboor(neighboor_dict[2], up_forbidden, down_forbidden, left_forbidden, right_forbidden)
			# 7 cannot have door up
			check_neighboor(neighboor_dict[7], true, false, false, false)
			# 5 CAN have door left
			check_neighboor(neighboor_dict[5], false, false, false, false)
			# 4 cannot have door right
			check_neighboor(neighboor_dict[4], false, false, false, true)
			# 2 cannot have door down
			check_neighboor(neighboor_dict[2], false, true, false, false)
		RoomType.R10x10_1W_TOP:			
			## check_neighboor(neighboor_dict[2], up_forbidden, down_forbidden, left_forbidden, right_forbidden)
			# 7 cannot have door up
			check_neighboor(neighboor_dict[7], true, false, false, false)
			# 5 cannot have door left
			check_neighboor(neighboor_dict[5], false, false, true, false)
			# 4 cannot have door right
			check_neighboor(neighboor_dict[4], false, false, false, true)
			# 2 CAN have door down
			check_neighboor(neighboor_dict[2], false, false, false, false)	
	
	
func check_neighboor(room_pos: Vector2i, up_forbidden : bool, down_forbidden : bool, left_forbidden : bool, right_forbidden : bool) -> void:
	## A room cannot be x negative or y negative
	if room_pos.x < 0 or room_pos.y < 0:
		return
		
	## A room cannot exceed the grid either
	if room_pos.x > dimensions.x - 1 or room_pos.y > dimensions.y - 1:
		return
	
	## Before checking those neighboors, make sure they exists
	if room_map[room_pos.x][room_pos.y].room_identifier == "":
		#print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") doesn't exist so skip")
		return	
	
	## Check if this room is already fine as it doesn't have anything forbidden
	if not up_forbidden and not down_forbidden and not left_forbidden and not right_forbidden:
		## Nothing is forbidden, so we simply return
		#print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") doesn't have anything forbidden, so skip")
		return
		
		
	var neighboor: RoomData = room_map[room_pos.x][room_pos.y]
	var neigh_kind : BaseRoom.RoomKind = neighboor.room_instance.kind
	var neigh_type : RoomType = neighboor.room_instance.type
	var neigh_pos : Vector2i = neighboor.world_position
	var neigh_instance : BaseRoom = neighboor.room_instance
	
	## We need to check because there is something forbidden. 	
	## We check each of them and swap from a 4W to a 3W or from a 3W to a 2W or from a 2W to a 1W, removing the forbidden door
	## We don't need to check for 1W rooms, they cannot be wrong.
	## We need to check 4W, 3W and 2W
	
	if up_forbidden:
		## Check for invalid 2Ways room
		if neigh_type == RoomType.R10x10_2W_TOP_LEFT:			
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_LEFT, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_TOP_RIGHT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_RIGHT, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_VERTICAL:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_BOTTOM")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_BOTTOM, neigh_kind)
		## Check for invalid 3ways room		
		elif neigh_type == RoomType.R10x10_3W_LEFT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_BOTTOM_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_BOTTOM_LEFT, neigh_kind)
		elif neigh_type == RoomType.R10x10_3W_RIGHT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_BOTTOM_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_BOTTOM_RIGHT, neigh_kind)
		elif neigh_type == RoomType.R10x10_3W_TOP:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_HORIZZONTAL")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_HORIZZONTAL, neigh_kind)
		##lastly check for invalid 4w
		elif neigh_type == RoomType.R10x10_4W:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_3W_BOTTOM")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_3W_BOTTOM, neigh_kind)
	elif down_forbidden:
		## Check for invalid 2Ways room
		if neigh_type == RoomType.R10x10_2W_BOTTOM_LEFT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_LEFT, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_BOTTOM_RIGHT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_RIGHT, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_VERTICAL:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_TOP")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_TOP, neigh_kind)
		## Check for invalid 3ways room
		elif neigh_type == RoomType.R10x10_3W_BOTTOM:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_HORIZZONTAL")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_HORIZZONTAL, neigh_kind)
		elif neigh_type == RoomType.R10x10_3W_LEFT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_TOP_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_TOP_LEFT, neigh_kind)
		elif neigh_type == RoomType.R10x10_3W_RIGHT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_TOP_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_TOP_RIGHT, neigh_kind)
		##lastly check for invalid 4w
		elif neigh_type == RoomType.R10x10_4W:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_3W_TOP")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_3W_TOP, neigh_kind)
	elif left_forbidden:
		## Check for invalid 2Ways room
		if neigh_type == RoomType.R10x10_2W_BOTTOM_LEFT:			
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_BOTTOM")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_BOTTOM, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_HORIZZONTAL:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_RIGHT, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_TOP_LEFT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_TOP")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_TOP, neigh_kind)
		## Check for invalid 3ways room
		elif neigh_type == RoomType.R10x10_3W_BOTTOM:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_BOTTOM_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_BOTTOM_RIGHT, neigh_kind)		
		elif neigh_type == RoomType.R10x10_3W_LEFT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_VERTICAL")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_VERTICAL, neigh_kind)		
		elif neigh_type == RoomType.R10x10_3W_TOP:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_TOP_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_TOP_RIGHT, neigh_kind)
		##lastly check for invalid 4w
		elif neigh_type == RoomType.R10x10_4W:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_3W_RIGHT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_3W_RIGHT, neigh_kind)
	elif right_forbidden:
		## Check for invalid 2Ways room
		if neigh_type == RoomType.R10x10_2W_BOTTOM_RIGHT:			
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_BOTTOM")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_BOTTOM, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_HORIZZONTAL:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_LEFT, neigh_kind)
		elif neigh_type == RoomType.R10x10_2W_TOP_RIGHT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_1W_TOP")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_1W_TOP, neigh_kind)
		## Check for invalid 3ways room
		elif neigh_type == RoomType.R10x10_3W_BOTTOM:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_BOTTOM_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_BOTTOM_LEFT, neigh_kind)		
		elif neigh_type == RoomType.R10x10_3W_RIGHT:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_VERTICAL")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_VERTICAL, neigh_kind)
		elif neigh_type == RoomType.R10x10_3W_TOP:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_2W_TOP_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_2W_TOP_LEFT, neigh_kind)
		##lastly check for invalid 4w
		elif neigh_type == RoomType.R10x10_4W:
			print("this room (x:" + str(room_pos.x) + " y:" + str(room_pos.y) + ") should change to a RoomType.R10x10_3W_LEFT")
			neigh_instance.queue_free()
			place_room(neigh_pos, RoomType.R10x10_3W_LEFT, neigh_kind)	
			
## This function will print the dungeon matching the actual room placements in the world, so we can see what's been generated. Meant for debugging.
func reverse_print_level() -> void:
	var level_as_string : String = ""
	
	## Iterate Y from top to bottom
	for y in range (dimensions.y - 1, -1, -1):
		## Iterate X in REVERSE order to match the game view (mirrored)
		for x in range(dimensions.x - 1, -1, -1):
			if room_map[x][y].room_identifier != "":
				level_as_string += "[" + room_map[x][y].room_identifier + "]"	
			else:
				level_as_string += "[     ]"		
			
		level_as_string += '\n'
	
	print(level_as_string)
	
## This function will print the dungeon matching the actual room placements in the world, but with the identifier we also print the x,y coordinates of the map
func reverse_print_level_map() -> void:
	var level_as_string : String = ""
	
	## Iterate Y from top to bottom
	for y in range (dimensions.y - 1, -1, -1):
		## Iterate X in REVERSE order to match the game view (mirrored)
		for x in range(dimensions.x - 1, -1, -1):
			if room_map[x][y].room_identifier != "":
				level_as_string += "[" + room_map[x][y].room_identifier + "](" + str(x) + "," + str(y) + ")"
			else:
				level_as_string += "["+ str(x) + "," + str(y) +"]"		
			
		level_as_string += '\n'
	
	print(level_as_string)

## This function will print the level grid matching the actual room placements in the world, which contains rooms positions Meant for debugging.
func reverse_print_level_grid() -> void:
	var level_as_string : String = ""
	
	## Iterate Y from top to bottom
	for y in range (dimensions.y - 1, -1, -1):
		## Iterate X in REVERSE order to match the game view (mirrored)
		for x in range(dimensions.x - 1, -1, -1):			
			level_as_string += "[" + str(room_map[x][y].world_position) + "]"			
		level_as_string += '\n'
	
	print(level_as_string)

## Returns the seed used for generation. If no seed was set (seed < 0), returns the randomly generated seed that was used.
func get_used_seed() -> int:
	return rng.seed
