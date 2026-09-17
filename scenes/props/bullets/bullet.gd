extends Node3D

## Bullet
##
## This handles the behaviour of the bullet

const SPEED = 40.0

const TIMER_FOR_PARTICLES = 1.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D
@onready var particles: GPUParticles3D = $GPUParticles3D

func _process(delta: float) -> void:
	## Move the bullet forward
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	
	## Check for collisions
	if ray.is_colliding():
		## Hide the mesh
		mesh.visible = false
		## Show the particles spark
		particles.emitting = true
		## Create a timer so we can wait for the particles to be done emitting
		await get_tree().create_timer(TIMER_FOR_PARTICLES).timeout
		## Delete the bullet now that the timer is done
		queue_free()

## Timer that will delete the bullet after a given (10s) time so it doesn't fly indefinitely clogging resources
func _on_timer_timeout() -> void:
	## Delete the bullet
	queue_free()
