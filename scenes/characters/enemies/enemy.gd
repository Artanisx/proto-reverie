class_name Enemy
extends CharacterBody3D

## Enemy class.
##
## This handles any Enemy scene

const EQUIPPED_ITEM_PREFAB := preload("res://scenes/equipment/equipped_item.tscn")	## The "Equipped" Item prefab; this is where the weapon will be placed in the enemy's body ("equipped" in his body!!)

## To be used to "stick" the player thrown weapon into
@onready var physical_bone_torso: PhysicalBone3D = %"Physical Bone Torso"

## This function will allow the enemy to be impaled by the player's thrown weapon
## thrown_item is the item that should be attached/rendered
## basis is the  transform (rotation etc) we want the impaled item to be
func impale(thrown_item: ThrownItem, basis: Basis) -> void:
	var impaled_item := EQUIPPED_ITEM_PREFAB.instantiate() as EquippedItem
	impaled_item.weapon_data = thrown_item.weapon_data		## The thrown item data should be passed to the equipped (impaled) item! If it's ana xe, an axe should be passed etc	
	physical_bone_torso.add_child(impaled_item) 			## Then, add this instance to the torso, for proper impalation!
	impaled_item.global_transform.basis = basis				## Then apply the basis (transform) so that it is rotated in the right position
	impaled_item.translate_object_local(impaled_item.weapon_data.impale_local_translation)	## Apply the specific translation to this weapon
	impaled_item.rotate_object_local(Vector3.UP, impaled_item.weapon_data.impale_local_rotation) ## Apply the specific rotation to this weapon	
	thrown_item.queue_free()								## Finally, get rid of the thowrn item since it's now being placed in the equipment (torso impalation!)
