class_name Enemy
extends CharacterBody3D

## Enemy class.
##
## This handles any Enemy scene

@onready var animation_player: AnimationPlayer = $character/AnimationPlayer
@onready var equipment: EquipmentComponent = %EquipmentComponent
@onready var health: HealthComponent = %HealthComponent

## To be used to "stick" the player thrown weapon into
@onready var physical_bone_torso: PhysicalBone3D = %"Physical Bone Torso"

## To be used for ragdoll physics
@onready var skeleton_simulator: PhysicalBoneSimulator3D = %PhysicalBoneSimulator3D
@onready var collision_shape: CollisionShape3D = %CollisionShape

## To be used for detecting the player
@onready var player_detection_area: Area3D = %PlayerDetectionArea


@export var duration_between_attacks : int 	## How often the enemy attacks, in ms
@export var player : Player					## Player reference
@onready var weapon_reach_raycast: RayCast3D = %WeaponReachRaycast	## needed to check wheter the player is in range facing the enemy


enum State {MOVING, IMPALING, DYING, DEAD, SLASHING, HURT}

var state : State	## State the enemy is in
var state_node : EnemyState ## The Node that holds the current state the enemy is in
var time_since_last_attack: int  ## Needed for timing the attacks, in ms

func _ready() -> void:
	## Connets the body_entered signal of the player detection area
	player_detection_area.body_entered.connect(on_player_detected)
	
	# Call the switch_state function to set the starting state
	switch_state(State.MOVING)

## This function will allow the enemy to be impaled by the player's thrown weapon
## thrown_item is the item that should be attached/rendered
## basis is the  transform (rotation etc) we want the impaled item to be
func impale(thrown_item: ThrownItem, item_basis: Basis) -> void:
	## Create an EnemyStateData class and fill it with the arguments needed for the impaling state	
	var state_data: EnemyStateData = EnemyStateData.new().set_thrown_item(thrown_item).set_thrown_item_basis(item_basis)	
	
	## Switch state to the IMPALING state, passing the state_data
	switch_state(State.IMPALING, state_data)

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
		State.HURT: EnemyStateHurt
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
func try_receive_hit(damage: int) -> void:
	switch_state(State.HURT, EnemyStateData.new().set_damage(damage)) ## Switch to the HURT state and pass damage

func on_player_detected(body: Player) -> void:
	## The player is in range, register it
	player = body
