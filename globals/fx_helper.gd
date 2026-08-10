extends Node

## FX HELPER
##
## This is a Global accesible to all the game. 
## Takes care of spawning visual effects like blood spurts.


## VFX PREFABS
const BLOOD_SPURT_PREFAB := preload("res://fx/blood_spurt.tscn")
const METAL_SPARK_PREFAB := preload("res://fx/metal_spark.tscn")

## Spawn a one shot blood particle effect
## blood_transform: postion of the effect
func create_blood_fx(blood_transform: Transform3D, show_sparks: bool = true) -> void:		
	## Instnatiate the blododpusrt node from the head
	var blood := BLOOD_SPURT_PREFAB.instantiate()	
	blood.are_sparks_shown = show_sparks
	GameState.current_level.add_child(blood)
	blood.global_transform = blood_transform
	
## Spawn a one shot metal spark particle effect
func create_metal_spark_fx(spark_position: Vector3) -> void:		
	## Instnatiate the metal spark node
	var sparks := METAL_SPARK_PREFAB.instantiate()		
	GameState.current_level.add_child(sparks)
	sparks.global_position = spark_position
