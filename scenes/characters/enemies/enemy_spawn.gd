class_name EnemySpawn
extends Node3D

## Enemy Spawn
##
## This Node3D is used to spawn enemies and it's manually placed inside a Room.
## The level generator will then spawn a single enemy (or not) inside of this node, that also provides an EnemyPosition Minimap sprite3D icon.

@onready var enemy_position_minimap: Sprite3D = %EnemyPosition_Minimap

var is_populated: bool = false ## If an enemy is assigned to this spawn, this is set to true

const StandardSword : WeaponData = preload("res://data/weapons/shortsword.tres")

const DEFAULT_DETECTION_RANGE: float = 5.0

## Populate this spawn point with an enemy
## Pass the enemy prefab as an argument
## Other arguments are optional and set the stats.
func set_enemy(enemy_prefab: PackedScene, duration_stun: float = 2.5, duration_between_attacks: int = 2000, enemy_speed: float = 2.0, enemy_exp_for_kill: int = 10, enemy_max_life: int = 8, weapon_data: WeaponData = StandardSword, enemy_detection_range: float = DEFAULT_DETECTION_RANGE, is_this_boss: bool = false) -> void:	
	if not is_populated:
		## First, instantiate the enemy
		var enemy: Enemy = enemy_prefab.instantiate()
		## Set its stats
		enemy.duration_stun = duration_stun
		enemy.duration_between_attacks = duration_between_attacks
		enemy.speed = enemy_speed
		enemy.exp_for_kill = enemy_exp_for_kill	
		enemy.is_boss = is_this_boss ## To set the enemy as boss if it's so	 WARNING: More than one enemy could be set as boss which is not expected behaviour
		
		## Pass over the minimap icon position (it was in the spawn for level editing purposes)
		enemy_position_minimap.visible = true		
		enemy_position_minimap.reparent(enemy, false)
		
		## Then, we add the enemy as a child of Enemies container (not Enemy Spawn)
		var enemies_container = get_parent()
		if enemies_container.name != "Enemies":
			printerr("EnemySpawn.gd [18] - Enemies container not found. Is the parent of this EnemySpawn not the Enemies container?")			
		enemies_container.add_child(enemy)
		
		## Stats that require components inside the enemy needs to be set after the enemy is added as a child
		enemy.health.max_life = enemy_max_life
		enemy.health.current_life = enemy.health.max_life
		enemy.global_transform = global_transform
		
		## If a new detection range different from the default has been passed, set a new range
		if enemy_detection_range != DEFAULT_DETECTION_RANGE:			
			var NewShape : SphereShape3D = SphereShape3D.new()
			NewShape.radius = enemy_detection_range
			enemy.player_detection_area.get_child(0).set_shape(NewShape)
		
		if enemy.equipment.weapon_data == null:
			enemy.equipment.equip_weapon(weapon_data) 	## Set the weapon data for the enemy
		
		
		## We mark this spawn as filled	
		is_populated = true
		## Spawner did its job so it should remove itself
		queue_free()
	else:
		## Trying to set_enemy on a populated EnemySpawn
		printerr("EnemySpawn.gd [13] - Trying to set_enemy() on an already populated EnemySpawn prefab.")
		return
