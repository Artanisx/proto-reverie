class_name HealthPackSpawn
extends Node3D

## HealthPackSpawn
##
## This Node3D is used to spawn Health Packs pickables and it's manually placed inside a Room.
## The level generator will then spawn a single Health Pack (or not) inside of this node, that also provides an Health Pack Minimap sprite3D icon.

var is_populated: bool = false ## If an healthpack is assigned to this spawn, this is set to true

## Populate this spawn point with an enemy
## Pass the healthpack prefab as an argument
## Other arguments are optional and set the stats.
func set_healthpack(healthpack_prefab: Pickable, rot_speed: float = 8.0, rot_dir: Pickable.Direction = Pickable.Direction.Y_AXIS, heal_amount: int = 20) -> void:
	if not is_populated:
		## First, instantiate the health pack
		var healthpack: Pickable = healthpack_prefab.instantiate()
		## Set its stats
		healthpack.rotation_speed = rot_speed
		healthpack.rotation_direction = rot_dir
		healthpack.heal_amount = heal_amount
		healthpack.pickCollectible = Pickable.PickCollectible.HEALTH
		## Then, we add the enemy as a child of Picables container (not HealthPack Spawn)
		var pickables_container  = get_parent()
		if pickables_container.name != "Pickables":
			printerr("HealthPack_Spawn.gd [19] - Pickables container not found. Is the parent of this HealthPackSpawn not the Pickables container?") 
		pickables_container.add_child(healthpack)
		## We mark this spawn as filled	
		is_populated = true
	else:
		## Trying to set_enemy on a populated EnemySpawn
		printerr("HealthPack_Spawn.gd [13] - Trying to set_healthpack() on an already populated HealthPackSpawn prefab.")
		return
