class_name RoomData
extends RefCounted

var room_identifier: String = ""  # e.g., "START", "CP:13", "ENDBR:1:2:2"
var world_position: Vector2i = Vector2i.ZERO  # e.g., Vector2i(21, 42)
var room_instance: BaseRoom = null  # The actual BaseRoom node

func _init(identifier: String = "", position: Vector2i = Vector2i.ZERO, instance: BaseRoom = null):
	room_identifier = identifier
	world_position = position
	room_instance = instance
