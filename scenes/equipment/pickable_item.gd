class_name PickableItem
extends StaticBody3D

## Pickable Item
##
## This contains the item that is currently on the floor and it is pickable. Will instantiate the mesh of it.
## The difference with the Equipped Item is that, of course, it's on the ground; so it must be pickable.

## This holds a material with the Albedo set to yellow, used for the highlight when the player RayCast hits it to show the item is pickable.
const HIGHLIGHT_MATERIAL := preload("res://materials/highlight_material.tres")

@export var mesh_node: MeshInstance3D
@export var weapon_data: WeaponData
@export var shield_data: ShieldData

@onready var collision_shape: CollisionShape3D = %CollisionShape		## Reference to the collision shape, since we'll need to create it dynamically depending on the item

var highlight_material : StandardMaterial3D

## As soon as the node is spawned we must:
## - Creates a duplicate of the highlight material
## - Create the mesh for the pickable item
## - Add it as a child
## - Create the proper collision shape
func _ready() -> void:
	## Create the highlight material (duplicating the base one)
	## This will be used by the highlight() func
	highlight_material = HIGHLIGHT_MATERIAL.duplicate()
	
	## Then, we instantiate the mesh
	var pickable_object : Node3D = null		
	if weapon_data:	## it's a weapon?
		pickable_object = weapon_data.glb_mesh.instantiate()
	elif shield_data: ## it's a shield then?
		pickable_object = shield_data.glb_mesh.instantiate()
		
	## Add it as a child and save the reference to the mesh node and finally create the collision shape	
	if pickable_object != null:
		add_child(pickable_object)
		mesh_node = pickable_object.get_child(0) as MeshInstance3D
	## If we assigned a mesh_node directly in the editor (for example, barrel) the above code won't be needed so it's fine that we don't have a weapon or shield data
	
	## However we do need to generate collision shape if the mesh_node is not null at this point	
	if mesh_node != null:
		collision_shape.shape = mesh_node.mesh.create_convex_shape()	
	
			
## Change the mesh material	with the highlight material
func highlight() -> void:
	mesh_node.material_override = highlight_material ## We don't do duplicate() here on the const material as we'd end up duplicating lots of materials each time the player looks at this..
	
## Change the mesh material	back with its original material 
func unhighlight() -> void:
	mesh_node.material_override = null	## reset the override (so it will default back to its original material)
	
