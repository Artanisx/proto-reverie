class_name EquippedItem
extends Node3D

## Equipped Item
##
## This contains the item that is currently equipped and will instantiate the mesh of it.

## This holds a special material for the weapons that has been created with the zclip scale option enabled (0.5)
## to be used for the player FPS camera so that the weapon cannot go in the walls. This is for the player only when he is holding the weapon.
const ZCLIP_MATERIAL := preload("res://materials/zclip_material.tres")

@export var is_always_in_front: bool
@export var weapon_data: WeaponData		## The Weapon Data resource of the equipped item.

## As soon as the node is spawned we must:
## - Create the mesh for the equipped item
## - Add it as a child
func _ready() -> void:
	## First, we instantiate the mesh
	var equipped_object := weapon_data.glb_mesh.instantiate()
	
	## Add it as a child, if it's not null
	if equipped_object != null:
		add_child(equipped_object)
		
		## Check if the node containing the mesh exists and it is set to be rendered in front (player FPS camera)
		var mesh_node := equipped_object.get_child(0) as MeshInstance3D
		if mesh_node != null and is_always_in_front:
			mesh_node.material_override = ZCLIP_MATERIAL.duplicate()	## Apply the zclip material that will be drawn in front; needs to be duplicated as it's a resource!
			
	
