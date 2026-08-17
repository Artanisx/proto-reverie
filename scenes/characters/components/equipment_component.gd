class_name EquipmentComponent
extends Node3D

## Equipment Component
##
## This is a component that can be added to Player or Enemies for handling the equipped item (weapon/shield).

const EQUIPPED_ITEM_PREFAB := preload("res://scenes/equipment/equipped_item.tscn")	## The Equipped Item prefab
const THROWN_ITEM_PREFAB := preload("res://scenes/equipment/thrown_item.tscn")	## The Thrown Item prefab


@export var is_always_in_front: bool	## If this is true, the equipped item will have its material replaced by the one with ZClip scale enabled to be drawn in front. Only set it true for the player.
@export var furniture_data: FurnitureData	## Furniture data of this "equipment"
@export var furniture_placeholder: Node3D	## The node reference where the furniture will be attached to (both hands)
@export var shield_data: ShieldData		## Shield data of this equipment
@export var shield_placeholder: Node3D	## The node reference where the Shield will be attached to (left hand basically)
@export var weapon_data: WeaponData		## Weapon data of this equipment
@export var weapon_placeholder: Node3D	## The node reference where the Equipment will be attached to (right hand)
@export var weapon_spawn_position: Node3D ## The position from where the thrownable weapon will spawn so it move in the right direction / rotation
@export var weapon_reach_raycast: RayCast3D	 ## Raycast to calculate the weapon reach, needed so it works only facing the enemy/player rather than from behind

## This does:
## - Equip the weapon and/or shield
func _ready() -> void:
	if weapon_data != null:
		equip_weapon(weapon_data)
	
	if shield_data != null:
		equip_shield(shield_data)

## Equips the correct shield based upon the shield Resource
## Takes two arguments:
## data: the shieldData of the item that should be instantiated in the equipped item scene
## pickup_transform: the Transform of the pickup itself, to be used for tweening between ground and the player's hand
func equip_shield(data: ShieldData, pickup_transform: Transform3D = Transform3D.IDENTITY) -> void:
	## check if the player already has a shield, so it will drop it before taking a new one
	if has_shield():
		drop_shield()
	
	## Since resources are shared between entities, we must make sure we create a copy of this.
	## Failing to do so, would make all weapons share the same durability for instance; an enemy might get his shield damaged and player's one would be damaged as well.
	## Since Godot handles resources per reference, we need to manually copy it instead.
	shield_data = data.duplicate() ## Create a duplicate of the WeaponData passed as reference
	
	## Instantiate the equipped item
	var shield := EQUIPPED_ITEM_PREFAB.instantiate() as EquippedItem
	
	## Setup the weapon data for this 
	shield.shield_data = shield_data
	
	## Setup wheter the weapon should be on front of the player camera (i.e. player is holding it)
	shield.is_always_in_front = is_always_in_front
	
	## Add this instance as a child of the weapon placeholder
	shield_placeholder.add_child(shield)
		
	## Check if we passed a transform (so we want to do a tween)
	if pickup_transform != Transform3D.IDENTITY:
		shield.global_transform = pickup_transform		## Set the shield's transform to the object on the ground transform position
		animate_to_hand(shield)

## Equips the correct furniture based upon the furniture Resource
## Takes two arguments:
## data: the furnitureData of the item that should be instantiated in the equipped item scene
## pickup_transform: the Transform of the pickup itself, to be used for tweening between ground and the player's hand
func equip_furniture(data: FurnitureData, pickup_transform: Transform3D = Transform3D.IDENTITY) -> void:
	## If the player has a shield and/or weapon, we don't want to drop them, but we want to hide them
	if has_shield():
		hide_shield()
		
	if has_weapon():
		hide_weapon()
	
	## Since resources are shared between entities, we must make sure we create a copy of this.
	## Failing to do so, would make all weapons share the same durability for instance; an enemy might get his shield damaged and player's one would be damaged as well.
	## Since Godot handles resources per reference, we need to manually copy it instead.
	furniture_data = data.duplicate() ## Create a duplicate of the data passed as reference
	
	## Instantiate the equipped item
	var furniture := EQUIPPED_ITEM_PREFAB.instantiate() as EquippedItem
	
	## Setup the furniture data for this 
	furniture.furniture_data = furniture_data
	
	## Setup wheter the furniture should be on front of the player camera (i.e. player is holding it)
	furniture.is_always_in_front = is_always_in_front
	
	## Add this instance as a child of the furniture placeholder
	furniture_placeholder.add_child(furniture)
		
	## Check if we passed a transform (so we want to do a tween)
	if pickup_transform != Transform3D.IDENTITY:
		furniture.global_transform = pickup_transform		## Set the furniture's transform to the object on the ground transform position
		animate_to_hand(furniture)

## Hides the shield, used when equipping a furniture
func hide_shield() -> void:
	shield_placeholder.visible = false

## Hides the weapon, used when equipping a furniture
func hide_weapon() -> void:
	weapon_placeholder.visible = false
	
## Shows back the shield, used when throwing a furniture
func show_shield() -> void:
	shield_placeholder.visible = true

## Shows back the weapon, used when throwing a furniture
func show_weapon() -> void:
	weapon_placeholder.visible = true

## Equips the correct weapon based upon the Weapon Resource
## Takes two arguments:
## data: the weaponData of the item that should be instantiated in the equipped item scene
## pickup_transform: the Transform of the pickup itself, to be used for tweening between ground and the player's hand
func equip_weapon(data: WeaponData, pickup_transform: Transform3D = Transform3D.IDENTITY) -> void:
	## check if the player already has a weapon, so it will drop it before taking a new one
	if has_weapon():
		drop_weapon()
		
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
	
	## Update the lenght of the raycast to the weapon's reach (square root just for performance)
	weapon_reach_raycast.target_position.z = -sqrt(weapon_data.reach)
	
	## Since we just equipped the weapon, let's emit this event because the player now has a weapon that didn't have previously
	GameEvents.weapon_changed.emit(weapon_data)
	
	## Check if we passed a transform (so we want to do a tween)
	if pickup_transform != Transform3D.IDENTITY:
		weapon.global_transform = pickup_transform		## Set the weapon's transform to the object on the ground transform position
		animate_to_hand(weapon)



## Thrown the currently equipped weapon	
func thrown_weapon(is_being_dropped: bool = false) -> void:
	if has_weapon():
		## Instantiate the thrown item
		var thrown_item := THROWN_ITEM_PREFAB.instantiate() as ThrownItem
		thrown_item.weapon_data = weapon_data ## weapon data is the equipped weapon data of course
		thrown_item.is_being_dropped = is_being_dropped ## Save the arugment, to see if the waepon should be dropped or it being thrown
		
		## Save the weapon_placeholder position (hands)
		var spawn_transform := weapon_placeholder.global_transform
		if not is_being_dropped:
			spawn_transform = weapon_spawn_position.global_transform ## startting position should be where the weapon spawn position is, not in the hands (weapon_placeholder)
		
		thrown_item.global_transform = spawn_transform	## Apply the transform depending on the above
		
		## Add this instance as a child of the current loaded level  (not the player or it would be attached to it)
		GameState.current_level.add_child(thrown_item)	## the weapon will drop to the ground atm
		
		## Destroy the weapon in hand
		weapon_data = null
		weapon_placeholder.get_child(0).queue_free()		
				
		## Since we just thrown the weapon, let's emit this event because the player doens't have the weapon anymore	
		GameEvents.weapon_changed.emit(weapon_data)
		
## Thrown the currently equipped furniture	
func thrown_furniture(is_being_dropped: bool = false) -> void:
	if has_furniture():
		## Instantiate the thrown item
		var thrown_item := THROWN_ITEM_PREFAB.instantiate() as ThrownItem
		thrown_item.furniture_data = furniture_data ## weapon data is the equipped weapon data of course
		thrown_item.is_being_dropped = is_being_dropped ## Save the arugment, to see if the waepon should be dropped or it being thrown
		
		## Save the furniture_placeholder position (hands)
		var spawn_transform := furniture_placeholder.global_transform		
		
		thrown_item.global_transform = spawn_transform	## Apply the transform depending on the above
		
		## Add this instance as a child of the current loaded level  (not the player or it would be attached to it)
		GameState.current_level.add_child(thrown_item)	## the weapon will drop to the ground atm
		
		## Destroy the furniture in hand
		furniture_data = null
		furniture_placeholder.get_child(0).queue_free()		
		
		##Show again both eapon and shield
		show_weapon()
		show_shield()
				
		## Give a force to be thrown
		#thrown_item.apply_impulse(Vector3.FORWARD * thrown_force, thrown_item.global_position)		

## drop thefurntire
func drop_furniture() -> void:
	thrown_furniture(true)

## Drop thje weapon rather than trhow it
func drop_weapon() -> void:
	thrown_weapon(true)
	
## Drop the shield :(
func drop_shield() -> void:
	if has_shield():
		## Instantiate the thrown item
		var dropped_item := THROWN_ITEM_PREFAB.instantiate() as ThrownItem
		dropped_item.shield_data = shield_data ## shield data is the equipped shjield data of course		
		dropped_item.is_being_dropped = true ## we are dropping th e shield
		
		## Save the shield_placeholder position (hands)
		var spawn_transform := shield_placeholder.global_transform
		
		dropped_item.global_transform = spawn_transform	## Apply the transform depending on the above
		
		## Add this instance as a child of the current loaded level  (not the player or it would be attached to it)
		GameState.current_level.add_child(dropped_item)	## the weapon will drop to the ground atm
		
		## Destroy the shield in hand
		shield_data = null
		shield_placeholder.get_child(0).queue_free()		

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

## Check if there's a shield equipped
func has_shield() -> bool:	
	## If there's shield data and there's an instance in the shield placeholder...
	return shield_data != null and shield_placeholder.get_child_count() > 0
	
## Check if there's a weapon equipped
func has_weapon() -> bool:	
	## If there's weapon data and there's an instance in the weapon placeholder...
	return weapon_data != null and weapon_placeholder.get_child_count() > 0
	
## Check if there's a furniture equipped
func has_furniture() -> bool:	
	## If there's furniture data and there's an instance in the furniture placeholder...
	return furniture_data != null and furniture_placeholder.get_child_count() > 0

## Reduce durability of the equipped weapon
func apply_weapon_damage(amount: int) -> void:
	if has_weapon():
		## Decrease the condition
		weapon_data.decrease_condition(amount)
		
		## If the weapon is destroyed by this...
		if weapon_data.condition <= 0:
			drop_weapon()	##drop it
		
		## Since we just changed the durability of the weapon, let's emit this event	
		GameEvents.weapon_changed.emit(weapon_data)
