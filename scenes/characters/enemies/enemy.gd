class_name Enemy
extends CharacterBody3D

## Enemy class.
##
## This handles any Enemy scene

const DURATION_RAGDOLL_SIMULATION : float = 3.0
const EQUIPPED_ITEM_PREFAB := preload("res://scenes/equipment/equipped_item.tscn")	## The "Equipped" Item prefab; this is where the weapon will be placed in the enemy's body ("equipped" in his body!!)
const IMPALE_INTENSITY : float = 100.0


## To be used to "stick" the player thrown weapon into
@onready var physical_bone_torso: PhysicalBone3D = %"Physical Bone Torso"

## To be used for ragdoll physics
@onready var skeleton_simulator: PhysicalBoneSimulator3D = %PhysicalBoneSimulator3D
@onready var collision_shape: CollisionShape3D = %CollisionShape


## This function will allow the enemy to be impaled by the player's thrown weapon
## thrown_item is the item that should be attached/rendered
## basis is the  transform (rotation etc) we want the impaled item to be
func impale(thrown_item: ThrownItem, item_basis: Basis) -> void:
	var impaled_item := EQUIPPED_ITEM_PREFAB.instantiate() as EquippedItem
	impaled_item.weapon_data = thrown_item.weapon_data		## The thrown item data should be passed to the equipped (impaled) item! If it's ana xe, an axe should be passed etc	
	physical_bone_torso.add_child(impaled_item) 			## Then, add this instance to the torso, for proper impalation!
	impaled_item.global_transform.basis = item_basis				## Then apply the basis (transform) so that it is rotated in the right position
	impaled_item.translate_object_local(impaled_item.weapon_data.impale_local_translation)	## Apply the specific translation to this weapon
	impaled_item.rotate_object_local(Vector3.UP, impaled_item.weapon_data.impale_local_rotation) ## Apply the specific rotation to this weapon	
	thrown_item.queue_free()								## Finally, get rid of the thowrn item since it's now being placed in the equipment (torso impalation!)
	
	## Impalement is oneshot
	register_death(item_basis * Vector3.FORWARD * IMPALE_INTENSITY + Vector3.UP * IMPALE_INTENSITY) 	## We apply a bit of impulse forward and up

## This function will start the ragdoll for the death
## Optionally we can apply an impulse force so it is receiving the impact
func register_death(impulse: Vector3 = Vector3.ZERO) -> void:
	## 1- Disable collision shape since we are no longer handling phsyics with it
	collision_shape.disabled = true
	## 2- Enable the skeleton simulator
	skeleton_simulator.active = true
	## 3- Start the simulation (ragdoll)
	skeleton_simulator.physical_bones_start_simulation() ## we could only specific which bones are able to move, for example only the feet if mipaled to a wall, here we pass them all because we want them to all move)
	## 4- APply the impulse force t  othe torso since the weapon attaches itself to the torso
	physical_bone_torso.apply_impulse(impulse)
	## 5- After a few seconds, let's stop the simulation so parts don't keep wobbling
	var timer := get_tree().create_timer(DURATION_RAGDOLL_SIMULATION)	## Create atimer of the set duration
	timer.timeout.connect(freeze_ragdoll)								## Set its callback rto the timeout signal
	
## This function will freeze the ragdoll simulation	
func freeze_ragdoll() -> void:
	## Make each individual bone to go to sleep
	for child in skeleton_simulator.get_children():
		if child is PhysicalBone3D:
			var bone := child as PhysicalBone3D
			var bone_rid := child.get_rid() as RID
			PhysicsServer3D.body_set_state(bone_rid, PhysicsServer3D.BODY_STATE_SLEEPING, true)
