class_name PlayerStatePickingUp
extends PlayerState

## Player State: PickingUp
##
## This handles the behaviour for the player state: State.PICKING_UP
## It contains all processing, signals, etc required for this state
## Transitions:
## Picking Up > Moving

## Execute what needs to be done immediately when the node enters the tree, so when we switch to this state (basically kind of a _ready)	
func  _enter_tree() -> void:
	## Play the pickup animation
	player.animation_player.play("pickup")
	
	## Hookup to the finish signal
	player.animation_player.animation_finished.connect(on_animation_finished)
	
	## Pickup the item that is being looked at
	var picakable_object := player.current_pickable_focused_item	
	
	## if the pickable object contains weapon data (so it is.. a weapon!) and the player hasn't already euqipped a weapon...
	if picakable_object.weapon_data != null: 
		player.equipment.equip_weapon(picakable_object.weapon_data, picakable_object.global_transform) ## pick it up (set the equpment component to the weapon data of the piackable object, also pass its position - the transform - for a little tween animation)
		picakable_object.queue_free()	## destroys the picakable object since it is now equpped
	
func on_animation_finished(_animation_name: String) -> void:	
	transition_state(Player.State.MOVING)	## Emit the signal and transition to Moving
