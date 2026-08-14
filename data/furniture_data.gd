class_name FurnitureData
extends Resource

## Furniture Data Resource.
##
## This contains just data for fornitures, like barrels, in the format of a Resource.
## It has a regular mesh (when not broken) and a mesh for fragments.

@export var name: String
@export var glb_mesh: PackedScene
@export var glb_fragemnts_mesh: PackedScene
@export var throw_rotation_speed: float	## Furniture Rotation Speed while in air
@export var throw_movement_speed: float	## Furniture Movement Speed while in air
