class_name BaseLevel
extends Node3D

## This class is a BaseLevel from which all other levels inherit.
##
## The main goal of this script is to spawn the Player in the Player Spawn point.

const PLAYER_PREFAB := preload("res://scenes/characters/player/player.tscn")

@onready var player_spawn: Node3D = %PlayerSpawn

func _ready() -> void:
	var player : Player = PLAYER_PREFAB.instantiate()
	player.global_transform = player_spawn.global_transform
	add_child(player)
