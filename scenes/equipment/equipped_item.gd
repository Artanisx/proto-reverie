class_name EquippedItem
extends Node3D

## Equipped Item
##
## This contains the item that is currently equipped and will instantiate the mesh of it.

## This holds a special material for the weapons that has been created with the zclip scale option enabled (0.5)
## to be used for the player FPS camera so that the weapon cannot go in the walls. This is for the player only when he is holding the weapon.
const ZCLIP_MATERIAL := preload("res://materials/zclip_material.tres")

@export var is_always_in_front: bool
@export var furniture_data: FurnitureData	## The Furniture Data of the possibly "equipped" furniture
@export var shield_data: ShieldData		## The Shield Data resource of the equipped item.
@export var weapon_data: WeaponData		## The Weapon Data resource of the equipped item.

## As soon as the node is spawned we must:
## - Create the mesh for the equipped item
## - Add it as a child
func _ready() -> void:
	var equipped_object : Node = null
	
	## If we have a weapon inside...
	if weapon_data:
		## We instantiate the mesh for the weapon
		equipped_object = weapon_data.glb_mesh.instantiate()
	elif shield_data:
		## Not a weapon, so if there's a shield, we isntanziate the mesh for the shield then
		equipped_object = shield_data.glb_mesh.instantiate()
	elif furniture_data:
		## Not a weapon or shield, so it's a furniture, we instantiate the mesh for the furniture then
		equipped_object = furniture_data.glb_mesh.instantiate()
		
	## Add it as a child, if it's not null
	if equipped_object != null:
		add_child(equipped_object)
		
		## Check if the node containing the mesh exists and it is set to be rendered in front (player FPS camera)
		var mesh_node := equipped_object.get_child(0) as MeshInstance3D
		if mesh_node != null and is_always_in_front:
			mesh_node.material_override = ZCLIP_MATERIAL.duplicate()	## Apply the zclip material that will be drawn in front; needs to be duplicated as it's a resource!
			

## Returns an animationplayer if it exists (only on the gun)
func get_animation_player() -> AnimationPlayer:
	var node = get_children()[0] ## get the "model" scene of this equipped item
	
	for kid : Node in node.get_children():
		if kid is AnimationPlayer: ## find the Animation player children if it exists
			return kid
	
	return null
	
## Returns a raycast if it exists (only on the gun)
func get_raycast() -> RayCast3D:
	var node = get_children()[0] ## get the "model" scene of this equipped item
	
	for kid : Node in node.get_children():
		if kid is RayCast3D: ## find the raycast 3d children if it exists
			return kid
	
	return null
