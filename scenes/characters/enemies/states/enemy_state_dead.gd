class_name EnemyStateDead
extends EnemyState

## Enemy State: Dead
##
## This handles the behaviour for the Enemy state: State.Dead
## It contains all processing, signals, etc required for this state
## Transitions:
## None

## We need to make all bones go to sleep so they stop juggling
## This will freeze the ragdoll simulation	
func _enter_tree() -> void:
	## Make each individual bone to go to sleep
	for child in enemy.skeleton_simulator.get_children():
		if child is PhysicalBone3D:
			var bone := child as PhysicalBone3D
			var bone_rid := bone.get_rid() as RID
			PhysicsServer3D.body_set_state(bone_rid, PhysicsServer3D.BODY_STATE_SLEEPING, true)
