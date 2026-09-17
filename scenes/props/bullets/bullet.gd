extends Node3D

## Bullet
##
## This handles the behaviour of the bullet

const SPEED = 40.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D


func _process(delta: float) -> void:
	## Move the bullet forward
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
