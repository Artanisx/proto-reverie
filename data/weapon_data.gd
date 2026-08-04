class_name WeaponData
extends Resource

## Weapon Data Resource.
##
## This contains data for a Weapon in the format of a Resource.

@export var name: String		## Weapon Name
@export var condition: int		## Current Weapon Durability
@export var max_condition: int	## Max Weapon Durability
@export var damage_min: int		## Weapon minimum damage
@export var damage_max: int		## Weapon maximum damage
@export var impale_local_translation: Vector3 ## Depending on the weapon, the position (offset) it should have for a proper impalement positioning 
@export var impale_local_rotation: float ## Depending on the weapon, the rotation (angle) it should have for a proper impalement positioning 
@export var reach: float		## Weapon Range (how far the weapon can reach enemies with a swing)
@export var throw_rotation_speed: float	## Weapon Rotation Speed while in air
@export var throw_movement_speed: float	## Weapon Movement Speed while in air
@export var glb_mesh: PackedScene		## Weapon Mesh (.glb file)

## Calculates a damage amount between min and max
func get_damage_dealt() -> int:
	return randi_range(damage_min, damage_max)

## Decreases durability
func decrease_condition(amount: int) -> void:
	condition = clampi(condition - amount, 0, max_condition)
