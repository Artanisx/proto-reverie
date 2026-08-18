class_name EnemyStateImpaling
extends EnemyState

## Enemy State: Impaling
##
## This handles the behaviour for the Enemy state: State.Impaling
## It contains all processing, signals, etc required for this state
## Transitions:
## Impaling > Dying

const EQUIPPED_ITEM_PREFAB := preload("res://scenes/equipment/equipped_item.tscn")	## The "Equipped" Item prefab; this is where the weapon will be placed in the enemy's body ("equipped" in his body!!)
const IMPALE_INTENSITY : float = 100.0

func _enter_tree() -> void:
	## Apply the Hit Stop juice for highlighting the action - This will pause the game for a bit.
	GameEvents.impact_felt.emit(GameEvents.ImpactIntensity.MEDIUM)
	
	AudioManager.play("impale", enemy.action_audio_stream_player) ## Play the SFX
	
	var impaled_item := EQUIPPED_ITEM_PREFAB.instantiate() as EquippedItem
	impaled_item.weapon_data = state_data.thrown_item.weapon_data		## The thrown item data should be passed to the equipped (impaled) item! If it's ana xe, an axe should be passed etc	
	enemy.physical_bone_torso.add_child(impaled_item) 			## Then, add this instance to the torso, for proper impalation!
	impaled_item.global_transform.basis = state_data.thrown_item_basis				## Then apply the basis (transform) so that it is rotated in the right position
	impaled_item.translate_object_local(impaled_item.weapon_data.impale_local_translation)	## Apply the specific translation to this weapon
	impaled_item.rotate_object_local(Vector3.UP, impaled_item.weapon_data.impale_local_rotation) ## Apply the specific rotation to this weapon	
	state_data.thrown_item.queue_free()								## Finally, get rid of the thowrn item since it's now being placed in the equipment (torso impalation!)
	
	## Impalement is oneshot, so transition to dying
	
	## We apply a bit of impulse forward and up
	var impulse: Vector3 = state_data.thrown_item_basis * Vector3.FORWARD * IMPALE_INTENSITY + Vector3.UP * IMPALE_INTENSITY	
	
	## Instnatiate the blododpusrt node from the head
	FxHelper.create_blood_fx(enemy.physical_bone_head.global_transform)
	
	## Transition to DYING state passing the impulse we calculated to a new enemystatedata with impulse set
	transition_state(Enemy.State.DYING, EnemyStateData.new().set_impulse(impulse))	
