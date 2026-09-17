extends Node3D

## Bullet
##
## This handles the behaviour of the bullet

const SPEED = 40.0
const TIMER_FOR_PARTICLES = 1.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var audio_stream_player: AudioStreamPlayer3D = %AudioStreamPlayer3D

func _process(delta: float) -> void:
	## Move the bullet forward
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	
	## Check for collisions
	if ray.is_colliding():		
		## Hide the mesh
		mesh.visible = false
		## Show the particles spark
		particles.emitting = true
		##DIsable the ray or we will trigger multiple collisions
		ray.enabled = false
		
		if ray.get_collider() is Enemy:
			print("Enemyu hit!!!")
			## First, let's calcualte the damage the bullet causes
			var damage := GameState.current_player.equipment.weapon_data.get_damage_dealt() + GameState.current_player.player_strength ## Include player stregnth in damage calculation
	
			ray.get_collider().try_receive_hit(GameState.current_player, damage)
		else:
			AudioManager.play("sword-hit-wall", audio_stream_player) ## Plays the SFX only if it's the bullet  hitting the wall, and play it only once
		
		
		## Create a timer so we can wait for the particles to be done emitting
		await get_tree().create_timer(TIMER_FOR_PARTICLES).timeout
		## Delete the bullet now that the timer is done
		queue_free()

## Timer that will delete the bullet after a given (10s) time so it doesn't fly indefinitely clogging resources
func _on_timer_timeout() -> void:
	## Delete the bullet
	queue_free()
