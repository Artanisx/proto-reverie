class_name DroppedKey
extends RigidBody3D

## This class is a Dropped Key; this will be dropped by an Enemy and can be used to open colored doors.
##
## The main goal of this script is to handle these keys.

const ROTATION_SPEED : float = 10.0 ## How quickly should the key rotate
const EMISSION_ENERGY : float = 2.5 ## The energy multiplier for the emission material of the key. How much it should "glow"

@export var color: Door.KeyColor ## Which KeyColor this is (basically which door this key will open)
@export var mesh: MeshInstance3D ## Set to the Key mesh

@onready var omni_light: OmniLight3D = %OmniLight3D
@onready var player_detection_area: Area3D = %PlayerDetectionArea


func _ready() -> void:
	## First we need to set the color of the material so it matches the KeyColor
	var material := mesh.get_active_material(0) as StandardMaterial3D
	material.albedo_color = Door.COLOR_MAP[color] ## Using the DOOR.COLOR_MAP we "translate" from Door.KeyColor to actual color
	material.emission_enabled = true
	material.emission = Door.COLOR_MAP[color]	## We also want this color to be emissive
	material.emission_energy_multiplier = EMISSION_ENERGY
	
	omni_light.light_color = Door.COLOR_MAP[color] ##Also set the light color
	
	## Apply an angular velocity on the X axis so this key rotates
	angular_velocity = Vector3.UP * ROTATION_SPEED
	
	## Connect the collision signal
	player_detection_area.body_entered.connect(on_player_entered)
	
## PLayer pick up function	
func on_player_entered(_body: Player) -> void:
	## Emit the event the player picked up the key so a sound can be played and the key is registered by the player.gd and ui
	GameEvents.key_picked_up.emit(color)
	## Destroy the key as it was picked up
	queue_free()
