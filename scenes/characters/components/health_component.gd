class_name HealthComponent
extends Node

## Health Component
##
## This is a component that can be added to Player or Enemies for handling their health.

@export var max_life: int
@export var current_life: int

## Reduce the health by the passed argument
func take_damage(damage: int) -> void:	
	current_life = clampi(current_life - damage, 0, max_life)	
	
## Returns true if the character is dead
func is_dead() -> bool:	
	return current_life == 0	
