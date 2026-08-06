class_name ShieldData
extends Resource

## Shield Data Resource.
##
## This contains data for a Shield in the format of a Resource.

@export var name: String		## Weapon Name
@export var condition: int		## Current Weapon Durability
@export var max_condition: int	## Max Weapon Durability
@export var glb_mesh: PackedScene		## Shield Mesh (.glb file)

## Decreases durability
func decrease_condition(amount: int) -> void:
	condition = clampi(condition - amount, 0, max_condition)
