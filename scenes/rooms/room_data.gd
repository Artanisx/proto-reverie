class_name RoomData
extends RefCounted

## This class is used to store RoomData to be used in the BaseProceduralLevel.
##
## The main goal of this class is to be used inside the room_map Array that defines the whole level[br]
## It has three member variables:
## 1- room_identifier: a String that holds the name of the room  e.g., "START", "CP:13", "ENDBR:1:2:2"
## 2- world_position: a Vector2i that holds the world position of the room e.g., Vector2i(21, 42)
## 3- room_instance: a BaseRoom that holds the refernece of the spawned BaseRoom instance;[br] useful for replacement as in the check_generated_level() function in the base_procedural_level.gd file

var room_identifier: String = ""
var world_position: Vector2i = Vector2i.ZERO
var room_instance: BaseRoom = null

## Initialize a RoomData object with the passed parameters (or default ones)
func _init(identifier: String = "", position: Vector2i = Vector2i.ZERO, instance: BaseRoom = null) -> void:
	room_identifier = identifier
	world_position = position
	room_instance = instance
