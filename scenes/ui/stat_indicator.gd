class_name StatIndicator
extends ColorRect

## StatIndicator class
##
## This contains code used by the StatIndicator ui scene that handles the progress bar
## Can be used for Player Health and in general for any stat that should be displayed as a bar

@export var high_value_color: Color = Color.LIME_GREEN ## The color the progress bar should be if the value is high (>75%)
@export var med_value_color: Color = Color.GREEN_YELLOW ## The color the progress bar should be if the value is med (>50%)
@export var low_value_color: Color = Color.DARK_ORANGE ## The color the progress bar should be if the value is low (>25%)
@export var very_low_value_color: Color = Color.DARK_RED ## The color the progress bar should be if the value is very low (<25%)

@onready var progress_bar: TextureRect = %ProgressBar	## The progress bar texture (the "tick") that will fill in the bar


## Refreshes the value of the bar (the tickness of the tick texture) to properly fill the progressbar itself
## current_value: The value of the property (hp for example)
## max_value: The max value of the property
## The arguments are used to properly calculate the percentage of the bar that  should be filled
func refresh(current_value: int, max_value: int) -> void:	
	## any value <= 0 means the size is 0, Empty bar
	if current_value <= 0:
		progress_bar.size.x = 0
	
	## Now we calculate the actual size the bar should be depending on values
	var percentage := (float(current_value) / float(max_value)) * 100.0
	
	## Set the progress bar size to the calculated value (1-100)
	progress_bar.size.x = percentage
	
	## Set the color of the texture (modulate) depending on wheter it is low, med or high
	
	if percentage > 75:
		progress_bar.modulate = high_value_color
	elif percentage > 50:
		progress_bar.modulate = med_value_color
	elif percentage > 25:
		progress_bar.modulate = low_value_color
	else:
		progress_bar.modulate = very_low_value_color	
