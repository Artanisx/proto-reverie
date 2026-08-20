class_name Pickable
extends RigidBody3D

## This class is a Pickable; this is an pickable collectible that can be dropped by an Enemy or simply found on the floor.
##
## The main goal of this script is to handle these collectibles. It's a base class, so specific collectible (with different graphics) can be inherited by this.

@export var rotation_speed : float = 0.0 ## How quickly this pickable should rotate. Default has no rotation

@onready var player_detection_area: Area3D = %PlayerDetectionArea

enum PickCollectible {HEALTH, EXPCOIN}

var pickCollectible : PickCollectible	## Which Collectible this is
var heal_amount: int = 20 ## Amount of heal if it's healt pack

func _ready() -> void:
	## Connect the collision signal
	player_detection_area.body_entered.connect(on_player_entered)

func _process(delta: float) -> void:
	if rotation_speed > 0:
		## Apply an angular velocity on the X axis so this key rotates
		rotate(Vector3.UP, rotation_speed * delta)
		
## Player pick up function	
func on_player_entered(body: Player) -> void:
	## Emit the correct signal for each Pickable
	match pickCollectible:
		PickCollectible.HEALTH:
			## Check if the player is full; if he is don't pick this up
			if body.health.current_life == body.health.max_life:
				return
			body.health.heal_damage(heal_amount) ## Heal the player
			GameEvents.player_healed.emit(body) ## Emit the signal for UI
			AudioManager.play("key-pickup", body.vocal_audio_stream_player) ## Play SFX
			print("You picked up a Health Pack!")
		PickCollectible.EXPCOIN:
			print("You picked up a Exp Coin!")
		_:
			print("This isn't suposed to happen.")
	
	## Destroy the key as it was picked up
	queue_free()
