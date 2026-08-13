class_name AcidTrap
extends Node3D

## AcidTrap
##
## This handles the behaviour of the Acid Trap

@onready var body_detection_area: Area3D = %BodyDetectionArea

func _ready() -> void:
	## Connect to the body_entered signal to respond to collisions
	body_detection_area.body_entered.connect(on_body_entered)
	
## Function that handle collisions within this acid trap	
func on_body_entered(body: CharacterBody3D) -> void:
	## Calls the collider (player or enemy basically) take_acid_damage function
	body.take_acid_damage()
	
	
