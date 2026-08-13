class_name SpikesTrap
extends Area3D

## SpikesTrap
##
## This handles the behaviour of the Spikes Trap

func _ready() -> void:
	body_entered.connect(on_body_entered)
	
func on_body_entered(body: CharacterBody3D) -> void:
	body.take_spike_damage(self) ## Call the take_spike_damage() function on the character (enemy or player)
