class_name Door
extends StaticBody3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D

## Open the door!
func open(source_transform: Transform3D) -> void:
	## Door is open/opening so we should disble the collision shape to allow the player in
	collision_shape_3d.disabled = true
	
	## Calculate whtere to open the door to the left or to the right
	## If player and door look at the same direction (their vector forward is in the same direction) then...
	var door_forward := -global_basis.z
	var player_forward := -source_transform.basis.z
	
	## dot product will be positive if both vectors are looking at the same direction, negative otherwise
	var dot_product := door_forward.dot(player_forward)
	
	if dot_product > 0:
		## Play the right opening animation (towards Z NEGATIVE which is the default vector forward for player and door (and all items)
		animation_player.play("open-right")
	else:
		## Play the right opening animation (towards Z POSTIVIVE which is the opposite of default vector forward, so on the other side)
		animation_player.play("open-left")
	
