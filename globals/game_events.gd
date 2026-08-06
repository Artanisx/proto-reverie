extends Node

## Game Events
##
## This is a Global accesible to all the game. 
## Takes care of handling events (signals) that will happen in the game so its possible to perform actions.
## For example:
## - Hit Stop event that will add juice to an impact

enum ImpactIntensity {LOW, MEDIUM, HIGH}

## SIGNAL for the impact of an action, with a related intensity - Used for the "Hit Stop" functionality
signal impact_felt(intensity: ImpactIntensity)
