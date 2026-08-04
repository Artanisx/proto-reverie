class_name Enemy
extends CharacterBody3D

## Enemy class.
##
## This handles any Enemy scene

@onready var animation_player: AnimationPlayer = $character/AnimationPlayer
@onready var equipment: EquipmentComponent = %EquipmentComponent

## To be used to "stick" the player thrown weapon into
@onready var physical_bone_torso: PhysicalBone3D = %"Physical Bone Torso"

## To be used for ragdoll physics
@onready var skeleton_simulator: PhysicalBoneSimulator3D = %PhysicalBoneSimulator3D
@onready var collision_shape: CollisionShape3D = %CollisionShape

enum State {MOVING, IMPALING, DYING, DEAD}

var state : State	## State the enemy is in
var state_node : EnemyState ## The Node that holds the current state the enemy is in

func _ready() -> void:
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
		State.DEAD: EnemyStateDead
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
