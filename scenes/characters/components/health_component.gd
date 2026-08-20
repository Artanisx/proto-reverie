class_name HealthComponent
extends Node

## Health Component
##
## This is a component that can be added to Player or Enemies for handling their health.

@export var max_life: int
@export var current_life: int
@export var debug_mode: bool: ## If set to true, current hp is set to 1. Other debug stuff might be added here.
	set(new_debug_status):
		debug_mode = new_debug_status		
		if debug_mode:			
			print_rich("[color=yellow][b]WARNING:[/b] health_component.gd DEBUG MODE is [b]ON[/b][/color]")
			current_life = 1
		else:
			current_life = max_life	
	
## Reduce the health by the passed argument
func take_damage(damage: int) -> void:	
	current_life = clampi(current_life - damage, 0, max_life)

## Get a heal by the passed arugment	
func heal_damage(heal: int) -> void:
	current_life = clampi(current_life + heal, 0, max_life)
	
## Returns true if the character is dead
func is_dead() -> bool:	
	return current_life == 0	
