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
	RoomType.R10x10_1W_BOTTOM: preload("res://scenes/rooms/10x_10_1_way_room_bottom.tscn"),
	RoomType.R10x10_1W_LEFT: preload("res://scenes/rooms/10x_10_1_way_room_left.tscn"),
	RoomType.R10x10_1W_RIGHT: preload("res://scenes/rooms/10x_10_1_way_room_right.tscn"),
	RoomType.R10x10_1W_TOP: preload("res://scenes/rooms/10x_10_1_way_room_top.tscn"),
	RoomType.R10x10_2W_BOTTOM_LEFT: preload("res://scenes/rooms/10x_10_2_way_room_bottom_left.tscn"),
	RoomType.R10x10_2W_BOTTOM_RIGHT: preload("res://scenes/rooms/10x_10_2_way_room_bottom_right.tscn"),
	RoomType.R10x10_2W_HORIZZONTAL: preload("res://scenes/rooms/10x_10_2_way_room_horizzontal.tscn"),
	RoomType.R10x10_2W_TOP_LEFT: preload("res://scenes/rooms/10x_10_2_way_room_top_left.tscn"),
	RoomType.R10x10_2W_TOP_RIGHT: preload("res://scenes/rooms/10x_10_2_way_room_top_right.tscn"),
	RoomType.R10x10_2W_VERTICAL: preload("res://scenes/rooms/10x_10_2_way_room_vertical.tscn"),
	RoomType.R10x10_3W_BOTTOM: preload("res://scenes/rooms/10x_10_3_way_room_bottom.tscn"),
	RoomType.R10x10_3W_LEFT: preload("res://scenes/rooms/10x_10_3_way_room_left.tscn"),
	RoomType.R10x10_3W_RIGHT: preload("res://scenes/rooms/10x_10_3_way_room_right.tscn"),
	RoomType.R10x10_3W_TOP: preload("res://scenes/rooms/10x_10_3_way_room_top.tscn"),
	RoomType.R10x10_4W: preload("res://scenes/rooms/10x_10_4_way_room.tscn")
} 

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

@onready var rooms_container: Node3D = $Rooms


var level : Array ## This will store the array of rooms this level is composed of. For now, for t4esting purposes, it's npt a [BaseRoom] array. It will be so once done.
var level_grid : Array ## This  stores the level grid positions for each room
var branch_candidates : Array[Vector2i] ## List of room that can have branches added to them, so which rooms can support these detours

func _ready() -> void:
	initialize_level()
	place_entrance()
	generate_path(start, critical_path_length, "CP") # CP stands for CRITICAL PATH
	generate_branches()
	print_level()
	
	## Actual room placement
	calculate_room_positions() 
	print_level_grid()
	generate_level()
	
	## Finally call the super (baseroom) _ready function to initialize the player
	super()
	
## This function will procedurally generate the level assembling rooms
func initialize_level() -> void:
	## Initialize the level array
	for x in dimensions.x:
		level.append([])	# First we add empty arrays to form the columns of the map
		for y in dimensions.y:
			level[x].append(0) # Then for each y, we add a value that represent a empty room (0)
			
	## With Dimension X = 7 and Y = 5, at this point we have a 2d array with 7 columns and 5 rows, all filled with 0
	## [0][0][0][0][0][0][0]
	## [0][0][0][0][0][0][0]
	## [0][0][0][0][0][0][0]
	## [0][0][0][0][0][0][0]
	## [0][0][0][0][0][0][0]

## This function will print the dungeon, so we can see what's been generated. Meant for debugging.
func print_level() -> void:
	var level_as_string : String = ""
	
	## We count from top row and counting down to 0. Hence we start by y - 1 (array start at zero) and count -1, -1 to reach the top. We read from top to bottom.
	for y in range (dimensions.y - 1, -1, -1):
		for x in dimensions.x:
			if level[x][y]:	 ## if there's a room
				level_as_string += "[" + str(level[x][y]) + "]"	
			else:
				level_as_string += "[     ]"	## this is empty, there's no room		
			
		level_as_string += '\n'
	
	print(level_as_string)

## This function will print the level grid, which contains rooms positions Meant for debugging.
func print_level_grid() -> void:
	var level_as_string : String = ""
	
	## We count from top row and counting down to 0. Hence we start by y - 1 (array start at zero) and count -1, -1 to reach the top. We read from top to bottom.
	for y in range (dimensions.y - 1, -1, -1):
		for x in dimensions.x:			
			level_as_string += "[" + str(level_grid[x][y]) + "]"			
		level_as_string += '\n'
	
	print(level_as_string)
	
## This function will place the first room, where the player will spawn
func place_entrance() -> void:	
	## Check if the start position is valid. 
	## If it's outside of the map, it was not defined or it was defined improperly, in which case, pick at random.
	if start.x < 0 or start.x >= dimensions.x:
		start.x = randi_range(0, dimensions.x - 1)
	if start.y < 0 or start.y >= dimensions.y:
		start.y = randi_range(0, dimensions.y - 1)
		
	## We place the start room in the position predetermined. Could be a specific Room with a lift/portal to return to the hub, a hp station... something.
	level[start.x][start.y] = "START"
	
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
	match randi_range(0, 3):
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
			not level[current.x + direction.x][current.y + direction.y]):	## The value in these new coordinates must also be empty and not already contain a room
			current += direction	## This is all valid, so we can set this current position and proceed in this direction. Meaning, this is valid as the critical path			
			
			if length == 1 and marker == "CP":	
				## this is the last room of the critical path, so rather than marker, i want to put  ENDRO as end end room.
				level[current.x][current.y] = "ENDRO"
			else:
				## we mark this as the value passed as marker. If this is being called from the generation of the critical path, it will be a 'C', if not will be a number for the branches >>> NOT ANMIORE:We change the value of this position in the array to something different than 0; the lenght of the critical path. Basically we are adding a room here (for now it's an umber and it is the number of rooms towards the exit)
				level[current.x][current.y] = marker + "L:" + str(length) # I need to see the distance in the map
				
			## we don't want to create detours from the alst room or the start room, so lenght should be more than 1 and less than critical_path_legnth
			if length > 1 and length < critical_path_length:
				branch_candidates.append(current) ## We add this position in the map in the list of the branch_candidates, so room that can go somewhere else in a detour. This can only happen if we're not in the last room before the end (so lenght must be  > 1)
			
			if generate_path(current, length - 1, marker): ## We reduce the length of the critical path by 1 - starting from current - and call this again.				
				return true # it returned true, so we generated the whole thing, and the critical path is complete
			else:
				# it returned false, the critical path failed at some point. 
				branch_candidates.erase(current) ## since this is not valid, we remove it as a possible branch candidate from its list
				# We need to reverse the change we made and return back as it wasn't the right way to go
				level[current.x][current.y] = 0 ## set this room back to zero (empty)
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
		candidate = branch_candidates[randi_range(0, branch_candidates.size() -1)]
		# generate a new path from this candidate of the branch_length we set. the marker branches created plus 1 (so each branch will be 1,1,1 or 2,2,2 etc)
		if generate_path(candidate, randi_range(branch_length.x, branch_length.y), "B" + str(branches_created + 1)):
			branches_created += 1 #success
		else:
			branch_candidates.erase(candidate) #failure, remove this	

## This function will generate the whole level
func generate_level() -> void:
	var is_there_room_up: bool = false
	var is_there_room_down: bool = false
	var is_there_room_left: bool = false
	var is_there_room_right: bool = false
	
	for i in range(len(level_grid)):
		for j in range(len(level_grid[i])):  
			## First we check if there's a room
			if level[i][j]:				
				## CHeck if there's a room UP/DOWN/RIGHT/LEFT	
				if j-1 >= 0 and (level[i][j-1]):
					is_there_room_down = true					
				if j+1 < dimensions.y and (level[i][j+1]):
					is_there_room_up = true
				if i+1 < dimensions.x and (level[i+1][j]):
					is_there_room_right = true
				if i-1 >= 0 and (level[i-1][j]):
					is_there_room_left = true
					
				#print("I'm checking room name " + str(level[i][j]) + " that is i:" + str(i) + " j:" + str(j) + " in pos: " + str(level_grid[i][j]) + 
				#	  " and here's the deal. room_up:" + str(is_there_room_up) + " room_down: " + str(is_there_room_down) + " room_right: " + str(is_there_room_right) + "room_left: " + str(is_there_room_left))	
					
				if is_there_room_up and is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_4W)
				#	print("Placing a RoomType.R10x10_4W in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and is_there_room_down and not is_there_room_right and not is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_2W_VERTICAL)
				#	print("Placing a RoomType.R10x10_2W_VERTICAL in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and not is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_2W_HORIZZONTAL)
				#	print("Placing a RoomType.R10x10_2W_HORIZZONTAL in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and not is_there_room_right and not is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_1W_TOP)
				#	print("Placing a RoomType.R10x10_1W_TOP in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and not is_there_room_right and not is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_1W_BOTTOM)
				#	print("Placing a RoomType.R10x10_1W_BOTTOM in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and not is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_1W_RIGHT)
				#	print("Placing a RoomType.R10x10_1W_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and not is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_1W_LEFT)
				#	print("Placing a RoomType.R10x10_1W_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_2W_BOTTOM_RIGHT)
				#	print("Placing a RoomType.R10x10_2W_BOTTOM_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_2W_BOTTOM_LEFT)
				#	print("Placing a RoomType.R10x10_2W_BOTTOM_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_2W_TOP_RIGHT)
				#	print("Placing a RoomType.R10x10_2W_TOP_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_2W_TOP_LEFT)
				#	print("Placing a RoomType.R10x10_2W_TOP_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and not is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_3W_BOTTOM)
				#	print("Placing a RoomType.R10x10_3W_BOTTOM in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and is_there_room_down and not is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_3W_LEFT)
				#	print("Placing a RoomType.R10x10_3W_LEFT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif is_there_room_up and is_there_room_down and is_there_room_right and not is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_3W_RIGHT)
				#	print("Placing a RoomType.R10x10_3W_RIGHT in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				elif not is_there_room_up and is_there_room_down and is_there_room_right and is_there_room_left:
					place_room(level_grid[i][j], RoomType.R10x10_3W_TOP)
				#	print("Placing a RoomType.R10x10_3W_TOP in room name: " + str(level[i][j]) + " in pos" + str(level_grid[i][j]))
				
				## Resets flags for the next run
				is_there_room_up = false
				is_there_room_down = false
				is_there_room_left = false
				is_there_room_right = false	
				

## This function will actually place a room in the level
func place_room(room_position: Vector2i, type: RoomType = RoomType.R10x10_4W) -> void:
	## To start, we'll place R10x10_4W	
	var room : BaseRoom = ROOMS_MAP[type].instantiate()
	
	## Position the new room in the given coordinates
	room.position = Vector3(room_position.x, 0, room_position.y)
	
	## Add it to the rooms container as a child
	rooms_container.add_child(room)
	
## This function calculates the actual position in the level for the room.
## Puts the postiions in the level_grid array
func calculate_room_positions() -> void:	
	## Initialize the level_grid array
	for x in dimensions.x:
		level_grid.append([])	# First we add empty arrays to form the columns of the map
		for y in dimensions.y:
			level_grid[x].append(Vector2i.ZERO) # Then for each y, we add a position 0,0 as a start
			
	## With Dimension X = 7 and Y = 5, at this point we have a 2d array with 7 columns and 5 rows, all filled with Vector2i.ZERO
	## [0,0][0,0][0,0][0,0][0,0][0,0][0,0]
	## [0,0][0,0][0,0][0,0][0,0][0,0][0,0]
	## [0,0][0,0][0,0][0,0][0,0][0,0][0,0]
	## [0,0][0,0][0,0][0,0][0,0][0,0][0,0]
	## [0,0][0,0][0,0][0,0][0,0][0,0][0,0]
	
	## Start room will always be at 0,0 (we set it as such) position which is [0.DIMENSION.Y] as Y starts from the bottom
	
	for x in dimensions.x:
		for y in dimensions.y:
			level_grid[x][y] = Vector2i(x*room_size,y*room_size)
