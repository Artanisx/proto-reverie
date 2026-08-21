class_name ExpCoinSpawn
extends Node3D

## ExpCoinSpawn
##
## This Node3D is used to spawn ExpCoin pickables and it's manually placed inside a Room.
## The level generator will then spawn a single ExpCoin (or not) inside of this node, that also provides an ExpCoin Minimap sprite3D icon.

var is_populated: bool = false ## If an healthpack is assigned to this spawn, this is set to true

## Populate this spawn point with an enemy
## Pass the healthpack prefab as an argument
func set_expcoin(expcoin_prefab: Pickable) -> void:
	if not is_populated:
		## First, instantiate the health pack
		var expcoin = expcoin_prefab.instantiate()
		## Then, we add the enemy as a child of Picables container (not HealthPack Spawn)
		var pickables_container  = get_parent()
		if pickables_container.name != "Pickables":
			printerr("ExpCoin_Spawn.gd [19] - Pickables container not found. Is the parent of this ExpCoinSpawn not the Pickables container?") 
		pickables_container.add_child(expcoin)
		## We mark this spawn as filled	
		is_populated = true
	else:
		## Trying to set_enemy on a populated ExpCoinSpawn
		printerr("ExpCoin_Spawn.gd [13] - Trying to set_expcoin() on an already populated ExpCoinSpawn prefab.")
		return
