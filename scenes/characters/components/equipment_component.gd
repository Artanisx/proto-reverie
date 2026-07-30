class_name EquipmentComponent
extends Node3D

## Equipment Component
##
## This is a component that can be added to Player or Enemies for handling the equipped item (weapon/shield).

const EQUIPPED_ITEM_PREFAB := preload("res://scenes/equipment/equipped_item.tscn")	## The Equipped Item prefab

@export var is_always_in_front: bool	## If this is true, the equipped item will have its material replaced by the one with ZClip scale enabled to be drawn in front. Only set it true for the player.
@export var weapon_data: WeaponData		## Weapon data of this equipment
@export var weapon_placeholder: Node3D	## The node reference where the Equipment will be attached to

## This does:
## - Equip the weapon
func _ready() -> void:
	if weapon_data != null:
		equip_weapon(weapon_data)

## Equips the correct weapon based upon the Weapon Resource
func equip_weapon(data: WeaponData) -> void:
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
	
