class_name BloodSpurt
extends Node3D

## BloodSpurt node
## This is a node that contains two particle effects, one for the green blood spurt and one for sparks flyign around
## Instantiate this to have a oneshot effect of both particles

## References to the GPU Particle effects
@onready var blood: GPUParticles3D = %Blood
@onready var sparks: GPUParticles3D = %Sparks

## Once the node is instantiated, emit both particles
func _ready() -> void:
	sparks.emitting = true
	blood.emitting = true
	
	## Register to the signal of the finished effect (they are oneshots)
	blood.finished.connect(on_particles_done)
	
## Once the particle are done, let's destroy the node	
func on_particles_done() -> void:
	queue_free()
	
