class_name Pickable
extends RigidBody3D

## This class is a Pickable; this is an pickable collectible that can be dropped by an Enemy or simply found on the floor.
##
## The main goal of this script is to handle these collectibles. It's a base class, so specific collectible (with different graphics) can be inherited by this.

@export var rotation_speed : float = 0.0 ## How quickly this pickable should rotate. Default has no rotation
@export var rotation_direction: Direction ## Where this should go
@export var pickCollectible : PickCollectible	## Which Collectible this is
@export var model: Node3D ## The mesh, should be assigned, needed for rotations

@export var heal_amount: int = 0 ## Amount of heal if it's healt pack
@export var exp_amount: int = 0 ## Amount of experience if it's exp coin

@onready var player_detection_area: Area3D = %PlayerDetectionArea

enum PickCollectible {HEALTH, EXPCOIN}
enum Direction {X_AXIS, Y_AXIS, Z_AXIS}

var DIRECTION_MAP : Dictionary [Direction, Vector3] = {
	Direction.X_AXIS: Vector3.RIGHT,	
	Direction.Y_AXIS: Vector3.UP,	
	Direction.Z_AXIS: Vector3.BACK	
}

func _ready() -> void:
	## Connect the collision signal
	player_detection_area.body_entered.connect(on_player_entered)
	
	if model == null:
		printerr("Pickable.gd - You didn't set the Export Model in a Pickable. Which one? Uh.. this one: " + str(self))

func _process(delta: float) -> void:
	if rotation_speed > 0:
		## Apply an angular velocity on the X axis so this key rotates
		model.rotate_object_local(DIRECTION_MAP[rotation_direction], rotation_speed * delta)
		
## Player pick up function	
func on_player_entered(body: Player) -> void:
	## Emit the correct signal for each Pickable
	match pickCollectible:
		PickCollectible.HEALTH:
			## Check if the player is full; if he is don't pick this up
			if body.health.current_life == body.health.max_life:
				return
			## If heal amount is 0, don't do anything but report this in the log as it looks a mistake	
			if heal_amount == 0:
				printerr("Pickable.gd: Trying to pick a Helth Pack but heal_amount export var set to 0.")
				return
			body.health.heal_damage(heal_amount) ## Heal the player
			GameEvents.player_healed.emit(body) ## Emit the signal for UI
			AudioManager.play("key-pickup", body.vocal_audio_stream_player) ## Play SFX
			print("You picked up a Health Pack!")
		PickCollectible.EXPCOIN:
			## Check if the player is already max level; if he is don't pick this up
			if body.experience.current_level == body.experience.max_level:
				return
			## If exp amount is 0, don't do anything but report this in the log as it looks a mistake	
			if exp_amount == 0:
				printerr("Pickable.gd: Trying to pick a Helth Pack but exp_amount export var set to 0.")
				return
			body.experience.gain_experience(exp_amount)
			GameEvents.exp_up.emit(body) ## Emis the exp up signal	
			AudioManager.play("key-pickup", body.vocal_audio_stream_player) ## Play SFX
			print("You picked up a Exp Coin!")
		_:
			print("This isn't suposed to happen.")
	
	## Destroy the key as it was picked up
	queue_free()
