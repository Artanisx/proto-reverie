class_name ThrownItem
extends RigidBody3D

## Thrown Item
##
## This contains the item that is currently flying after it has been thrown. Will instantiate the mesh of it.
## The difference with the Equipped Item or Picked Item is that, of course, it's on the air flying. It must react to physics so it's a RigidBody3D

const DESTRUCTIBLE_ITEM_PREFAB := preload("res://scenes/props/destructible_item.tscn") ## THe destructible item prefab, needed if we are trhogin a destructible that needds to explode
const PICKABLE_ITEM_PREFAB := preload("res://scenes/equipment/pickable_item.tscn")	## The Pickable Item prefab, needed for transform it back to pickabel once trhwon

@export var furniture_data: FurnitureData
@export var shield_data: ShieldData
@export var weapon_data: WeaponData
@onready var collision_shape: CollisionShape3D = %CollisionShape
@onready var audio_stream_player: AudioStreamPlayer3D = %AudioStreamPlayer3D


## Store if the weapon is not thrown, but dropped (for example by a dead enemy)
var is_being_dropped: bool 

## Store the original rotation of this thrown item so that it can be reapplied once it's impaled (using the same direction/rotation for proper impalement)
var original_basis: Basis

## Store wheter this thrown item has hit the world (for use in play sound)
var has_hit_world : bool = false

## As soon as the node is spawned we must:
## - Create the mesh for the thrown item
## - Add it as a child
## - Create the proper collision shape
func _ready() -> void:	
	## Then, we instantiate the mesh
	var thrown_object : Node3D = null
	
	## Store the start rotation/transform
	original_basis = global_transform.basis
	
	## Define thrown movement and ortation speed based upon the item
	var thrown_movement_speed : float = 0.0
	var thrown_rotation_speed : float = 0.0
	var gravity : float = 0.8
	
	if weapon_data:
		thrown_object = weapon_data.glb_mesh.instantiate()
		thrown_movement_speed = weapon_data.throw_movement_speed
		thrown_rotation_speed = weapon_data.throw_rotation_speed
		gravity = 0 ##weapons don't hjave gravity so they go straight until they hit something
	elif shield_data:
		thrown_object = shield_data.glb_mesh.instantiate()
	elif furniture_data:
		thrown_object = furniture_data.glb_mesh.instantiate()
		thrown_movement_speed = furniture_data.throw_movement_speed
		thrown_rotation_speed = furniture_data.throw_rotation_speed
		
	## Add it as a child and save the reference to the mesh node and finally create the collision shape	
	if thrown_object != null:
		add_child(thrown_object)
		var mesh_node := thrown_object.get_child(0) as MeshInstance3D
		collision_shape.shape = mesh_node.mesh.create_convex_shape()
		
		if not is_being_dropped:		
			# Stop gravity so the object doesnt' fall to theground right away
			gravity_scale = gravity
			
			## Add to linear velocity, so it moves forward (z)
			linear_velocity = -global_basis.z * thrown_movement_speed
			
			## Add to angular_velocity in order to have some rotation
			angular_velocity = -global_basis.y * thrown_rotation_speed	
			
			if weapon_data != null:
				AudioManager.play("sword-fly", audio_stream_player) ## Plays the SFX only if it's a weapon that is thrown
		
		## Listen to the body_entered signal and call on_body_entered, needed for checking for collision with enemy/ground
		body_entered.connect(on_body_entered)	## This is to check wheter the weapon collides with an enemy

## This will be called each time the weapon collides with something
## However, we need this to happen only once per collision!
## The ThrownItem should have SOLVER>CONTACT MONITOR > ON and SOLVER>MAX CONTACT REPORT: 1 on the rigidbody3d component
func on_body_entered(body: Node) -> void:	
	## CHeck if we're trying to thrown furniture - so the item we trhwo nis furntirue
	if furniture_data != null: ## we're throgin af urntire instead		
		## Try to cause the enemy to receive furniture impact
		if body is Enemy and not is_being_dropped:
			var enemy := body as Enemy
			enemy.try_receive_furniture_impact(self)
				
		## first, we instantiat ethe destructible item
		var destructible_item := DESTRUCTIBLE_ITEM_PREFAB.instantiate() as DestructibleItem
		
		## set it sposition to the gloabl transform of the descrutible item scene
		destructible_item.global_transform = global_transform
		
		##Set the funrtire data
		destructible_item.furniture_data = furniture_data
		
		## Add it as a child of the world
		GameState.current_level.add_child(destructible_item)
		
		##Make it explode
		destructible_item.explode()
		
		## destroy the destruyctile item scene
		queue_free()
	else:	
		## We haven't thruonw a furnitre, so it might be aweapon thorwn or a shield dropped		
		
		if weapon_data != null and body is Enemy and not is_being_dropped:
			## the weapon is hitting an enemy and the weapon itself is thrown (and not simply dropping)...			
			var enemy := body as Enemy
			enemy.impale(self, original_basis)	## impale them!!!
		else:
			## The weapon is hitting the walls/ground etc... OR we have a shield that's been dropped to the floor		
			
			# First, apply gravity as soon as the item hits something
			gravity_scale = 1	
			
			if not has_hit_world:
				# Set  the variable to true since we hit the wall/world and didn't hit it already
				has_hit_world = true
				## The item (could be eithre the weapon OR a shield) just collided with something, fire the sleeping_state_changed
				## This signal is fired when the item goes to sleep which happens after godot stops checking for collisions, which happens after the item stops moving for a bit		
				sleeping_state_changed.connect(on_sleep)	## Create the connection only once (since it's in the not has_hit_world we're sure this is done only once)
				
				if weapon_data and not is_being_dropped:
					AudioManager.play("sword-hit-wall", audio_stream_player) ## Plays the SFX only if it's the weapon hitting the wall, and play it only once
				

## This will be called after the weapon stopped moving after being thrown somewhere
## At this point we'll need to transform the weapon from the thrownitem (flying state) to the pickableitem (item that can be picked up state)
func on_sleep() -> void:	
	# Swap from thrown item to pickable item
	
	## Instantiate the pickable item
	var pickable_item := PICKABLE_ITEM_PREFAB.instantiate() as PickableItem	
	pickable_item.weapon_data = weapon_data ## weapon data is the thrown weapon data of course
	pickable_item.shield_data = shield_data ## shield data is the thrown shield data of course (swap)
	pickable_item.global_transform = global_transform	## startting position should be where the thrown weapon is
	
	## Add this instance as a child of the level currently loaded (not the player or it would be attached to it)
	GameState.current_level.add_child(pickable_item)	## the weapon will be in the level, on the ground then
	
	## Destroy the thrown weapon	
	queue_free()	
