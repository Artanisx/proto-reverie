class_name PlayerStateHurt
extends PlayerState

## Player State: Hurt
##
## This handles the behaviour for the Player state: State.HURT
## It contains all processing, signals, etc required for this state
## Transitions:
## Hurt > Moving
## Hurt > Dying

const PUSHBACK_FORCE: float = 2.0 ## The force of knockback suffered when hit

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## We dont' have a hurt state yet, so let's just display some vfx for now
	GameEvents.player_hurt.emit(player)
	
	##check if the player is carrying funrtuire
	if player.equipment.has_furniture():
		## drop it
		player.equipment.drop_furniture()
		
	## Take damage
	player.health.take_damage(state_data.damage)	
	
	## Apply some pushback force from the direction of the impact (player)
	player.pushback_force += state_data.impact_direction * PUSHBACK_FORCE	
	
	## Apply the Hit Stop juice and camera (anything that subscribe to impact_felt) for highlighting the action - This will briefly pause the game
	GameEvents.impact_felt.emit(GameEvents.ImpactIntensity.MEDIUM)
	
	## Check wheter the enemy is still alive
	if player.health.is_dead():				
		transition_state(Player.State.DYING)	## Emit the signal and transition to Dying
	else:
		## Start the hurt timer		
		var timer := get_tree().create_timer(player.duration_hurt)	## Create atimer of the set duration
		timer.timeout.connect(on_hurt_finish)						## Set its callback rto the timeout signal

func _physics_process(delta: float) -> void:
	player.process_movement(delta) ## We need to process the movement
	
## This will transition back to the moving state[br]
func on_hurt_finish() -> void:	
	transition_state(Player.State.MOVING)	
