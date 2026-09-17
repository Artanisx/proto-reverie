extends Node

## Hit Stop Server
##
## This is a Global accesible to all the game. 
## It is a node, always processable (can't be paused) that will take care of pausing the processing of other nodes.

## Store the currently set impact intensity
var current_intensity : GameEvents.ImpactIntensity

## Dictonary that stores a pause amount in ms for each ImpactIntensity
var duration_map := {
	GameEvents.ImpactIntensity.LOW: 10,
	GameEvents.ImpactIntensity.MEDIUM: 70,
	GameEvents.ImpactIntensity.HIGH: 100
}

## Store the time and used for the timer
var time_since_start_pause := Time.get_ticks_msec()

## Are we currently paused?
var is_paused: bool = false

func _ready() -> void:
	## Make sure this node cannot be paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	## Connect to the impact_felt signal 
	## Meaning it will call the on_impact_felt() once the signal is emitted by something and thus received by this node.
	GameEvents.impact_felt.connect(on_impact_felt)

## This function will pause the game, following a specific ImpactIntenisty argument passed.
## It is used to perform the "hit stop" juice, briefly stopping action to highlight an impact.
func on_impact_felt(intensity: GameEvents.ImpactIntensity) -> void:
	## Pause the entire game
	get_tree().paused = true
	
	## Star the timer since we just paused
	time_since_start_pause = Time.get_ticks_msec()
	
	## Set the state as paused
	is_paused = true
	
	## Store the passed intensity
	current_intensity = intensity
	
func _process(_delta: float) -> void:
	## Start counting the time passed since pause was enabled
	var duration_since_paused := Time.get_ticks_msec() - time_since_start_pause
	
	## If the game is paused and we're paused enough (time in pause went over the related duration for the current_intensity)
	if is_paused and duration_since_paused > duration_map[current_intensity]:
		## Update the bool
		is_paused = false
		
		## Stop pause
		get_tree().paused = false
		
	
