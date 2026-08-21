class_name EnemySpawn
extends Node3D

## Enemy Spawn
##
## This Node3D is used to spawn enemies and it's manually placed inside a Room.
## The level generator will then spawn a single enemy (or not) inside of this node, that also provides an EnemyPosition Minimap sprite3D icon.

var is_populated: bool = false ## If an enemy is assigned to this spawn, this is set to true

## Populate this spawn point with an enemy
## Pass the enemy prefab as an argument
func set_enemy(enemy_prefab: Enemy) -> void:
	if not is_populated:
		## First, instantiate the enemy
		var enemy = enemy_prefab.instantiate()
		## Then, we add the enemy as a child of Enemies container (not Enemy Spawn)
		var enemies_container = get_parent()
		if enemies_container.name != "Enemies":
			printerr("EnemySpawn.gd [18] - Enemies container not found. Is the parent of this EnemySpawn not the Enemies container?")
		enemies_container.add_child(enemy)
		## We mark this spawn as filled	
		is_populated = true
	else:
		## Trying to set_enemy on a populated EnemySpawn
		printerr("EnemySpawn.gd [13] - Trying to set_enemy() on an already populated EnemySpawn prefab.")
		return
