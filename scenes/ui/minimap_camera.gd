class_name MinimapCamera
extends Camera3D

var player: Player = null

var offset : Vector3

## Links the player to the minimap camera
func set_player(player_set: Player) -> void:
	player = player_set
	offset = global_position - player.global_position
	
func _process(_delta: float) -> void:
	if player:
		## Updates the minimap camera position
		global_position = player.global_position + offset
	else:
		printerr("No player set in the Minimap camera.")
