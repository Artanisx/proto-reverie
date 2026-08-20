class_name Enemy
extends CharacterBody3D

## Enemy class.
##
## This handles any Enemy scene

## This signal is emitted when a enemy is hit by the player to warn the others
signal screamed

## This signal is emitted when a enemy dies
signal dead(death_transform: Transform3D)

const GRAVITY: float = 20.0
const AIR_FRICTION: float = 20.0

@onready var animation_player: AnimationPlayer = $character/AnimationPlayer
@onready var equipment: EquipmentComponent = %EquipmentComponent
@onready var health: HealthComponent = %HealthComponent

## To be used to "stick" the player thrown weapon into
@onready var physical_bone_torso: PhysicalBone3D = %"Physical Bone Torso"
## Refernece of the bone head to be used as a start point for the blood spurt particle effect
@onready var physical_bone_head: PhysicalBone3D = %"Physical Bone Head"

## To be used for ragdoll physics
@onready var skeleton_simulator: PhysicalBoneSimulator3D = %PhysicalBoneSimulator3D
@onready var collision_shape: CollisionShape3D = %CollisionShape

## To be used for detecting the player
@onready var player_detection_area: Area3D = %PlayerDetectionArea
@onready var weapon_reach_raycast: RayCast3D = %WeaponReachRaycast	## needed to check wheter the player is in range facing the enemy

@onready var presence_light: OmniLight3D = %PresenceLight

## TO be used for navigation
@onready var nav_agent: NavigationAgent3D = %NavigationAgent3D

## FOR AUDIO
@onready var action_audio_stream_player: AudioStreamPlayer3D = %ActionAudioStreamPlayer
@onready var vocal_audio_stream_player: AudioStreamPlayer3D = %VocalAudioStreamPlayer

## FOR UI
@onready var healthbar: Sprite3D = %Healthbar
@onready var health_indicator: StatIndicator = %HealthIndicator

@export var duration_stun : float			## Time in seconds for the duration of the stunned state
@export var duration_between_attacks : int 	## How often the enemy attacks, in ms
@export var player : Player					## Player reference
@export var speed: float					## Enemy movement speed
@export var exp_for_kill: int					## Enemy experience gain for kill


enum State {MOVING, IMPALING, DYING, DEAD, SLASHING, HURT, BLOCKING, STUNNED}

var pushback_force: Vector3 = Vector3.ZERO ## If set, it will cause this enemy to be pushed from this force (Vector3)
var state : State	## State the enemy is in
var state_node : EnemyState ## The Node that holds the current state the enemy is in
var time_since_last_attack: int  ## Needed for timing the attacks, in ms

func _ready() -> void:
	## Connets the body_entered signal of the player detection area
	player_detection_area.body_entered.connect(on_player_detected)
	
	## Refresh HP UI
	health_indicator.refresh(health.current_life, health.max_life)
	
	# Call the switch_state function to set the starting state
	switch_state(State.MOVING)

## This function will allow the enemy to be impaled by the player's thrown weapon
## thrown_item is the item that should be attached/rendered
## basis is the  transform (rotation etc) we want the impaled item to be
func impale(thrown_item: ThrownItem, item_basis: Basis) -> void:
	## Create an EnemyStateData class and fill it with the arguments needed for the impaling state	
	var state_data: EnemyStateData = EnemyStateData.new().set_thrown_item(thrown_item).set_thrown_item_basis(item_basis)
	
	## Check if the enemy is NOT aware of the player, does NOT have a shield or CAN get hurt
	if player == null or not equipment.has_shield() or state_node.can_get_hurt():
		## Switch state to the IMPALING state, passing the state_data
		switch_state(State.IMPALING, state_data)		
	else:
		## Switch state to the BLOCKING state, passing the state_data
		var hit_direction : Vector3 = thrown_item.global_position.direction_to(global_position)
		state_data.set_impact_direction(hit_direction)
		switch_state(State.BLOCKING, state_data)
		
	## Emit screamed signal to warn other enemies
	screamed.emit()
	
## This function will allow the enemy to be hit by a forntuire throw nby the player's
## thrown_item is the item that should be attached/rendered
## basis is the  transform (rotation etc) we want the impaled item to be
func try_receive_furniture_impact(thrown_item: ThrownItem) -> void:
	if equipment.has_shield():	
		## the enemy will drop his shield
		equipment.drop_shield()
		
		##calculate the hit direction (where is thefunrtire coming from)
		var hit_direction : Vector3 = thrown_item.global_position.direction_to(global_position)
		
		## Create an EnemyStateData class and fill it with the arguments needed for the impaling state	
		var state_data: EnemyStateData = EnemyStateData.new().set_impact_direction(hit_direction).set_knockback_force(2.5)
		
		## Switch to stunned state
		switch_state(State.STUNNED, state_data)
	else:
		## the enemy is vulnerable to be instantly killed by the furniture
		
		## Let's make sure the enemy's health is set to zero just to make sure isdead is properly set
		health.current_life = 0
		
		switch_state(State.DYING)

## Check if enemy knows the player exists (and it's still valid instance, so not dead/queued free)
func has_registered_player() -> bool:
	return player != null and is_instance_valid(player)
	
## Check if the player is within reach (melee range) in order to melee attack
func is_player_within_reach() -> bool:	
	if has_registered_player() and equipment.has_weapon():
		## Check if the player is in range of the weapon's reach and facing it (so it won't fire from behind)
		return weapon_reach_raycast.is_colliding()
	return false

## Switch to the passed State
## The function will add a Node that will contain the behaviour for the passed state
func switch_state(new_state: State, data: EnemyStateData = EnemyStateData.new()) -> void:
	## INIT: Remove the previous EnemyState node if it exists
	if state_node != null:
		state_node.queue_free()
	## 0 -- Create a dictionary containing all the states and related PlayerState classess
	var state_map := {
		State.MOVING: EnemyStateMoving,
		State.IMPALING: EnemyStateImpaling,
		State.DYING: EnemyStateDying,
		State.DEAD: EnemyStateDead,
		State.SLASHING: EnemyStateSlashing,
		State.HURT: EnemyStateHurt,
		State.BLOCKING: EnemyStateBlocking,
		State.STUNNED: EnemyStateStunned
	}	
	## 1 - Create the proper EnemyState node
	state_node = state_map[new_state].new(self, data)
	## 1.5 - Listen to the transition_state signal and connect to this function
	state_node.transition_requested.connect(switch_state)
	## 1.6 - Add a name to the node so it is clear in the tree
	state_node.name = "State_" + State.keys()[new_state]
	## 1.7 - Store the player state
	state = new_state	
	## 2 - Add it to the player scene	
	add_child(state_node)

## Check wheter the enemy will receive a hit
## This takes into account the enemy having a shield
## 1- source_player: the player causing the damage, used for position calculation for the knockback
## 2- damage: the damage amount
func try_receive_hit(source_player: Player, damage: int) -> void:
	## Register the player since they just hit the enemy
	player = source_player
	
	## Calc the hit direction from the player to this enemy
	var hit_direction : Vector3 = source_player.global_position.direction_to(global_position)
	
	## Calculate data to pass to switch_state
	var data := EnemyStateData.new().set_damage(damage).set_impact_direction(hit_direction)
	
	## If the enemy doesn't have a shield or if the enemy hasn't noticed the player yet (so it hasn't registered it) or if he can be hurt
	if player == null or not equipment.has_shield() or state_node.can_get_hurt():
		## THe enemy doesn't have a shield or hasn't seen the player, so they will take direct damage instead		
		switch_state(State.HURT, data) ## Switch to the HURT state and pass damage and direction
	else:
		## The enemy has a shield and has noticed the player, so they block instead of taking damage	
		switch_state(State.BLOCKING, data)  ## Switch to the BLOCKING state and pass direction  (well also damage, but won't be used)				

	## Emit screamed signal to warn other enemies
	screamed.emit()

## Check wheter the enemy will receive a kick
## This takes into account the enemy having a shield
## 1- source_player: the player causing the damage, used for position calculation for the knockback
func try_receive_kick(source_player: Player) -> void:
	## Register the player since they just kciked the enemy
	player = source_player
	
	## Calc the hit direction from the player to this enemy
	var hit_direction : Vector3 = source_player.global_position.direction_to(global_position)
	
	## Calculate data to pass to switch_state
	var data := EnemyStateData.new().set_impact_direction(hit_direction)
	
	## If the enemy is in a state that allows to be stunned OR he doesn't have a shield
	if state_node.can_get_stunned() or not equipment.has_shield():
		if state == State.STUNNED:
			## The enemy is already stunned, we'll prolong the stun (Stunned > Stunned is allowed), but change the knockback force to be bigger
			data.set_knockback_force(2.5)
		
		## The enemy doesn't have a shield or he is in a state that allows to be stunned		
		switch_state(State.STUNNED, data) ## Switch to the STUN state and pass the direction
	else:
		## The enemy has a shield or is in a state that cannot be stunned, so they block instead of be stunned
		switch_state(State.BLOCKING, data)  ## Switch to the BLOCKING state and pass direction  (well also damage, but won't be used)				

	## Emit screamed signal to warn other enemies
	screamed.emit()
	
## Check wheter the enemy will receive a stun
func try_stun() -> void:
	if state_node.can_get_stunned():
		switch_state(State.STUNNED)
	
## Take care of moving the Enemy
func process_movement(delta: float) -> void:
	## Apply Gravity
	process_gravity(delta)
	
	## Apply pushback forces (like knockback)
	process_pushback(delta)
	
	## Apply movement
	move_and_slide()
	
## Take care of gravity for the Enemy, being a rigidtbody we need to apply it oursevles
func process_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		
## Take care of processing push backs (like knockback after being hit) for the Enemy
func process_pushback(delta: float) -> void:
	## We must be sure the pushback force goes to zero as time goes on so it's not constant
	## Basically the force will slowly diminish towards 0
	## Since it's a rigidbody, phsyics wont' be applied so we need to take care of this ourselves
	pushback_force = pushback_force.move_toward(Vector3.ZERO, delta * AIR_FRICTION) 
	
	## Apply the pushback force to the velocity vector
	velocity += pushback_force

func on_player_detected(body: Player) -> void:
	## The player is in range, register it
	player = body

## Handles taking acid damage when in contact with the Acid Trap	
func take_acid_damage() -> void:
	## Acid is oneshot damage!
	
	## Let's make sure the enemy's health is set to zero just to make sure isdead is properly set
	health.current_life = 0
	
	if state_node.can_die(): ## Only if not already dying or dead, basically only in states that doesn't specifically disallow dying
		switch_state(State.DYING)
		
## To handle receiving damage from spikes trap
## For enemy this is an instant kill
func take_spike_damage(_spikes_trap: SpikesTrap) -> void:
	## spikes is oneshot damage!
	
	## Let's make sure the enemy's health is set to zero just to make sure isdead is properly set
	health.current_life = 0
	
	if state_node.can_die(): ## Only if not already dying or dead, basically only in states that doesn't specifically disallow dying
		AudioManager.play("spikes", action_audio_stream_player) ## Play the SFX
		switch_state(State.DYING)
	
