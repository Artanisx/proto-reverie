class_name Door
extends StaticBody3D

## Enum for KeyColors, each door can have one of these 4 keys
enum KeyColor {None, Blue, Red, Yellow, Purple}

## Static Variable so it is accessible from everywhere; it's a Map that links a KeyColor to an actual Color
static var COLOR_MAP : Dictionary [KeyColor, Color] = {
	KeyColor.Blue: Color.DARK_BLUE,	
	KeyColor.Red: Color.DARK_RED,	
	KeyColor.Yellow: Color.DARK_GOLDENROD,	
	KeyColor.Purple: Color.DARK_MAGENTA
}

const EMISSION_ENERGY : float = 2.5 ## The energy multiplier for the emission material of the key. How much it should "glow"

@export var door_color: KeyColor

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var frame: Node3D = %Frame
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var omni_light_3d_2: OmniLight3D = %OmniLight3D2


func _ready() -> void:
	## We need to make the frame visible only if the door has a key (so it will be of that key color)
	frame.visible = door_color != KeyColor.None
	
	## Update the door frame material override with the right color
	update_frame_color()
	
## Update the door frame material override with the right color	
func update_frame_color() -> void:
	if door_color != KeyColor.None:	
		## First we need to set the color of the material so it matches the KeyColor
		var mesh := frame.get_child(0) ## get the mesh for the door frame
		var material := mesh.get_active_material(0).duplicate() as StandardMaterial3D ##we need to duplicat ethis or else all doors frame will be the same color
		material.albedo_color = COLOR_MAP[door_color] ## Using the DOOR.COLOR_MAP we "translate" from Door.KeyColor to actual color
		material.emission_enabled = true
		material.emission = Door.COLOR_MAP[door_color]	## We also want this color to be emissive
		material.emission_energy_multiplier = EMISSION_ENERGY
		
		mesh.set_surface_override_material(0, material) ## apply the material to the surface material override
		
		omni_light_3d.light_color = Door.COLOR_MAP[door_color] ##Also set the light color
		omni_light_3d_2.light_color = Door.COLOR_MAP[door_color] ##Also set the light color	
	else:
		frame.hide()

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
	
	## Once adoor is opened if it had a frame it should be hidden
	frame.hide()
