class_name MinimapCamera
extends Camera3D

var player: Player = null

var offset : Vector3

signal minimap_ready

func set_player(player_set: Player) -> void:
	player = player_set
	offset = global_position - player.global_position
	
func _ready() -> void:
	minimap_ready.emit()
	if player:
		offset = global_position - player.global_position
	else:
		print("No player set in the minimap")

func _process(_delta: float) -> void:
	if player:
		global_position = player.global_position + offset
	else:
		minimap_ready.emit()
