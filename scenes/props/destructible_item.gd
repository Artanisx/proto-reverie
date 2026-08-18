class_name DestructibleItem
extends Node3D

## Destructible Item
##
## This contains an item that can be destroyed, meaning an item that has a fragement mesh and should swap betwen 
## the regualr mesh to the framentet mesh

const EXPLOSION_FORCE : float = 5.0

@export var furniture_data: FurnitureData
@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D


var destructible_object: Node3D = null

func _ready() -> void:
	## if there is a furniture data
	if furniture_data != null:
		## instantiate the FRAGEMENTS mesh 
		destructible_object = furniture_data.glb_fragemnts_mesh.instantiate()
	## chec if framgent mesh has been instnaitae	
	if destructible_object != null:
		## Add the mesh to the destructible object scene
		add_child(destructible_object)
		
		## We need to remove the collision layer world from all fragemnts children of the mesh, or player/enemeies wont' be able to move over the fragemtns
		for fragment: RigidBody3D in destructible_object.get_children():
			## set the world layer (1) to false (so this is not part of the world layer)
			fragment.set_collision_layer_value(1, false)

##Exploide this destructible object!!!!			
func explode() -> void:	
	if destructible_object != null:
		## Play SFX
		AudioManager.play("barrel-destroy", audio_stream_player_3d)
		
		## for each framgent we will apply as mall force to move them outward
		for fragment: RigidBody3D in destructible_object.get_children():
			## apply a immpulse to the global position fo the framgent of a vector legnth of postiion * force
			fragment.apply_impulse(fragment.position * EXPLOSION_FORCE, global_position)
			
		## some impact effect
		GameEvents.impact_felt.emit(GameEvents.ImpactIntensity.MEDIUM)
		
