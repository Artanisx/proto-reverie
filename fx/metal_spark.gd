class_name MetalSpark
extends GPUParticles3D

## MetalSpark node
## This is a node that contains 1 particle effects, for the metal sparks
## Instantiate this to have a oneshot effect

## Once the node is instantiated, emit both particles
func _ready() -> void:
	emitting = true
	
	## Register to the signal of the finished effect (it is a oneshot)
	finished.connect(on_particles_done)
	
## Once the particle are done, let's destroy the node	
func on_particles_done() -> void:
	queue_free()
	
