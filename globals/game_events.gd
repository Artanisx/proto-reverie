extends Node

## Game Events
##
## This is a Global accesible to all the game. 
## Takes care of handling events (signals) that will happen in the game so its possible to perform actions.
## For example:
## - Hit Stop event that will add juice to an impact

enum ImpactIntensity {LOW, MEDIUM, HIGH}

## SIGNAL for the impact of an action, with a related intensity - Used for the "Hit Stop" and Camera Shake functionality
signal impact_felt(intensity: ImpactIntensity)

## SIGNAL for when the player gets hurt - Used for the "HurtVignette" functionality in the UI and invoked with this "GameEvents.player_hurt.emit(self)"
signal player_hurt(player: Player)

## SIGNAL for when the player dies
signal player_dead

## SIGNAL for when the level needs to be restarted (HINT: to be used to load a new floor in proto-reverie?)
signal level_restarted

## SIGNAL for when the player spawns in the game
signal player_spawned(player: Player)

## SIGNAL for when a weapon is changed (dropped/thrown/durability lost)
signal weapon_changed(weapon_data: WeaponData)

## SIGNAL for when a shield is changed (dropped/thrown/durability lost)
signal shield_changed(shield_data: ShieldData)

## SIGNAL for when action that the player can take changed (to update the ActionPanel UI)
signal possible_action_changed(action: String)
