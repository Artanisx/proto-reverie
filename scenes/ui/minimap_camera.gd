class_name MinimapCamera
extends Camera3D

var offset : Vector3 = Vector3.ZERO

## Links the player global position to the minimap camera
func set_offset(player_glb_position: Vector3) -> void:
	var calculated_offset = Vector3(0.0, global_position.y - player_glb_position.y, 0.0)
	offset = calculated_offset	
	
func _process(_delta: float) -> void:
	## Updates the minimap camera position to the player global + offset
	global_position = GameState.current_player.global_position + offset
