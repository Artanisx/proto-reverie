class_name AcidTrap
extends Area3D

## AcidTrap
##
## This handles the behaviour of the Acid Trap

func _ready() -> void:
	## Connect to the body_entered signal to respond to collisions
	body_entered.connect(on_body_entered)
	
## Function that handle collisions within this acid trap	
func on_body_entered(body: Node3D) -> void:
	## Calls the collider (player or enemy basically) take_acid_damage function
	if body is Enemy or body is Player:
		body.take_acid_damage()	
