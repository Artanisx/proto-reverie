class_name Door
extends StaticBody3D

## Enum for KeyColors, each door can have one of these 4 keys
enum KeyColor {Blue, Red, Yellow, Purple}

## Static Variable so it is accessible from everywhere; it's a Map that links a KeyColor to an actual Color
static var COLOR_MAP : Dictionary [KeyColor, Color] = {
	KeyColor.Blue: Color.DARK_BLUE,	
	KeyColor.Red: Color.DARK_RED,	
	KeyColor.Yellow: Color.DARK_GOLDENROD,	
	KeyColor.Purple: Color.DARK_MAGENTA
}

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
	
