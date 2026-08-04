class_name EquipmentComponent
extends Node3D

## Equipment Component
##
## This is a component that can be added to Player or Enemies for handling the equipped item (weapon/shield).

const EQUIPPED_ITEM_PREFAB := preload("res://scenes/equipment/equipped_item.tscn")	## The Equipped Item prefab
const THROWN_ITEM_PREFAB := preload("res://scenes/equipment/thrown_item.tscn")	## The Thrown Item prefab


@export var is_always_in_front: bool	## If this is true, the equipped item will have its material replaced by the one with ZClip scale enabled to be drawn in front. Only set it true for the player.
@export var weapon_data: WeaponData		## Weapon data of this equipment
@export var weapon_placeholder: Node3D	## The node reference where the Equipment will be attached to
@export var weapon_spawn_position: Node3D ## The position from where the thrownable weapon will spawn so it move in the right direction / rotation

## This does:
## - Equip the weapon
func _ready() -> void:
	if weapon_data != null:
		equip_weapon(weapon_data)

## Equips the correct weapon based upon the Weapon Resource
## Takes two arguments:
## data: the weaponData of the item that should be instantiated in the equipped item scene
## pickup_transform: the Transform of the pickup itself, to be used for tweening between ground and the player's hand
func equip_weapon(data: WeaponData, pickup_transform: Transform3D = Transform3D.IDENTITY) -> void:
	## Since resources are shared between entities, we must make sure we create a copy of this.
	## Failing to do so, would make all weapons share the same durability for instance; an enemy might get his weapon damaged and player's one would be damaged as well.
	## Since Godot handles resources per reference, we need to manually copy it instead.
	weapon_data = data.duplicate() ## Create a duplicate of the WeaponData passed as reference
	
	## Instantiate the equipped item
	var weapon := EQUIPPED_ITEM_PREFAB.instantiate() as EquippedItem
	
	## Setup the weapon data for this 
	weapon.weapon_data = weapon_data
	
	## Setup wheter the weapon should be on front of the player camera (i.e. player is holding it)
	weapon.is_always_in_front = is_always_in_front
	
	## Add this instance as a child of the weapon placeholder
	weapon_placeholder.add_child(weapon)
	
	## Check if we passed a transform (so we want to do a tween)
	if pickup_transform != Transform3D.IDENTITY:
		weapon.global_transform = pickup_transform		## Set the weapon's transform to the object on the ground transform position
		animate_to_hand(weapon)

## Thrown the currently equipped weapon	
func thrown_weapon() -> void:
	if has_weapon():
		## Instantiate the thrown item
		var thrown_item := THROWN_ITEM_PREFAB.instantiate() as ThrownItem
		thrown_item.weapon_data = weapon_data ## weapon data is the equipped weapon data of course
		thrown_item.global_transform = weapon_spawn_position.global_transform	## startting position should be where the weapon spawn position is
		
		## Add this instance as a child of the current loaded level  (not the player or it would be attached to it)
		GameState.current_level.add_child(thrown_item)	## the weapon will drop to the ground atm
		
		## Destroy the weapon in hand
		weapon_data = null
		weapon_placeholder.get_child(0).queue_free()		
				
		## Give a force to be thrown
		#thrown_item.apply_impulse(Vector3.FORWARD * thrown_force, thrown_item.global_position)		

## Tween function to animate a weapon movement from ground to player hands
func animate_to_hand(equipped_item: EquippedItem) -> void:
	## Create a tween on the equipped_item that now is at the ground item trasform
	var tween := equipped_item.create_tween()
	
	## Set the transition to QUAD
	tween.set_trans(Tween.TRANS_QUAD)
	
	## Set the ease to out "starts out fast, then slows down"
	tween.set_ease(Tween.EASE_OUT)
	
	## Do two tweens in parallel: position and rotation
	
	## first, tween on the position property of the item, towards ZERO (player hand, or rather weapon placeholder), taking 0.4s
	tween.parallel().tween_property(equipped_item, "position", Vector3.ZERO, 0.4)
	
	##second, tween the rotation property of the item, towards ZERO (player hand, or rather weapon placeholder), taking 0.2s (faster)
	tween.parallel().tween_property(equipped_item, "rotation", Vector3.ZERO, 0.2)
	
## Check if there's a weapon equipped
func has_weapon() -> bool:
	## If there's weapon data and there's an instance in the weapon placeholder...
	return weapon_data != null and weapon_placeholder.get_child_count() > 0
