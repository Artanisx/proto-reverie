class_name ThrownItem
extends RigidBody3D

## Thrown Item
##
## This contains the item that is currently flying after it has been thrown. Will instantiate the mesh of it.
## The difference with the Equipped Item or Picked Item is that, of course, it's on the air flying. It must react to physics so it's a RigidBody3D

const PICKABLE_ITEM_PREFAB := preload("res://scenes/equipment/pickable_item.tscn")	## The Pickable Item prefab, needed for transform it back to pickabel once trhwon

@export var weapon_data: WeaponData
@onready var collision_shape: CollisionShape3D = %CollisionShape

## Store the original rotation of this thrown item so that it can be reapplied once it's impaled (using the same direction/rotation for proper impalement)
var original_basis: Basis

## As soon as the node is spawned we must:
## - Create the mesh for the thrown item
## - Add it as a child
## - Create the proper collision shape
func _ready() -> void:	
	## Then, we instantiate the mesh
	var thrown_object : Node3D = null
	
	## Store the start rotation/transform
	original_basis = global_transform.basis
	
	if weapon_data:
		thrown_object = weapon_data.glb_mesh.instantiate()
		
	## Add it as a child and save the reference to the mesh node and finally create the collision shape	
	if thrown_object != null:
		add_child(thrown_object)
		var mesh_node := thrown_object.get_child(0) as MeshInstance3D
		collision_shape.shape = mesh_node.mesh.create_convex_shape()
		
		# Stop gravity so the object doesnt' fall to theground right away
		gravity_scale = 0
		
		## Add to linear velocity, so it moves forward (z)
		linear_velocity = -global_basis.z * weapon_data.throw_movement_speed
		
		## Add to angular_velocity in order to have some rotation
		angular_velocity = -global_basis.y * weapon_data.throw_rotation_speed
		
		## Listen to the body_entered signal and call on_body_entered, needed for checking for collision with enemy/ground
		body_entered.connect(on_body_entered)	## This is to check wheter the weapon collides with an enemy

## This will be called each time the weapon collides with something
## However, we need this to happen only once per collision!
## The ThrownItem should have SOLVER>CONTACT MONITOR > ON and SOLVER>MAX CONTACT REPORT: 1 on the rigidbody3d component
func on_body_entered(body: Node) -> void:
	if body is Enemy:
		## the weapon is hitting an enemy...
		body.impale(self, original_basis)	## impale them!!!
	else:
		## The weapon is hitting the walls/ground etc...
		# First, apply gravity as soon as the item hits something
		gravity_scale = 1	
		
		## The item just collided with something, fire the sleeping_state_changed
		## This signal is fired when the item goes to sleep which happens after godot stops checking for collisions, which happens after the item stops moving for a bit		
		if not sleeping_state_changed.is_connected(on_sleep): ## However, since the on_body_entered will be called a few times, we make sure we call the callback only once
			sleeping_state_changed.connect(on_sleep)	## Create the connection only once

## This will be called after the weapon stopped moving after being thrown somewhere
## At this point we'll need to transform the weapon from the thrownitem (flying state) to the pickableitem (item that can be picked up state)
func on_sleep() -> void:	
	# Swap from thrown item to pickable item
	
	## Instantiate the pickable item
	var pickable_item := PICKABLE_ITEM_PREFAB.instantiate() as PickableItem	
	pickable_item.weapon_data = weapon_data ## weapon data is the thrown weapon data of course
	pickable_item.global_transform = global_transform	## startting position should be where the thrown weapon is
	
	## Add this instance as a child of the level currently loaded (not the player or it would be attached to it)
	GameState.current_level.add_child(pickable_item)	## the weapon will be in the level, on the ground then
	
	## Destroy the thrown weapon	
	queue_free()	
