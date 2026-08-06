class_name MainCamera
extends Camera3D

## Main Camera
##
## This contains camera shake effects, and it is the camera attached to the player (FPS Camera)

## Dictonary that stores a duration amount for the Camera Shake effect
## WARNING. If the same duration of the hit_stop_server is set, the camera won't shake because the duration will be also paused
## If you want the same duration here, you need to make this camera "process_mode = Node.PROCESS_MODE_ALWAYS" in _ready()
var duration_map : Dictionary[GameEvents.ImpactIntensity, int] = {
	GameEvents.ImpactIntensity.LOW: 140,
	GameEvents.ImpactIntensity.MEDIUM: 200,
	GameEvents.ImpactIntensity.HIGH: 260
}

## Store the currently set impact intensity
var current_intensity : GameEvents.ImpactIntensity

## Dictonary that stores the intensity of the Camera Shake effect (how much the camera will move)
var intensity_map : Dictionary[GameEvents.ImpactIntensity, float] = {
	GameEvents.ImpactIntensity.LOW: 0.1,
	GameEvents.ImpactIntensity.MEDIUM: 0.15,
	GameEvents.ImpactIntensity.HIGH: 0.2
}

## Store the time and used for the timer
var time_start_shaking := Time.get_ticks_msec()

## Are we currently shaking?
var is_shaking: bool = false

## Initial camera transform to come back after the shake
var initial_transform: Transform3D

func _ready() -> void:	
	## Connect to the impact_felt signal 
	## Meaning it will call the on_impact_felt() once the signal is emitted by something and thus received by this node.
	GameEvents.impact_felt.connect(on_impact_felt)
	
## This function will shake the camera, following a specific ImpactIntenisty argument passed.
## ImpactIntensity will govern both the duration and the intensity of the shake
func on_impact_felt(intensity: GameEvents.ImpactIntensity) -> void:	
	## Start the shaking if not already shaking
	if not is_shaking:
		## Set the state as shaking
		is_shaking = true
		
		## Star the timer since we just started shaking
		time_start_shaking = Time.get_ticks_msec()
		
		## Store the initial transform so we can come back to it
		initial_transform = transform
		
		## Store the passed intensity
		current_intensity = intensity
	
func _process(_delta: float) -> void:
	if is_shaking:
		## Start counting the time passed since pause was enabled
		var duration_since_start_shaking := Time.get_ticks_msec() - time_start_shaking
	
		## If the camera is shaking but hasn't being shaking enough (time in shake is still not enough)
		if duration_since_start_shaking < duration_map[current_intensity]:
			## Shake!
			## Get the shake_intenisyt from the map
			var shake_intensity := intensity_map[current_intensity]
			## Calculate an offset for the shake based upon the shake intensity, for X and Y (not Z)
			var offset := Vector3(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity), 0)
			
			## Move the original transform by the initial_transform + offset
			## We don't move from the transform directly or we would move the camera far away to never come back
			## So we always move the initial position of the camera
			transform.origin = initial_transform.origin + offset
		else:
			## We shaked enough, so we need to restore the initial position and stop shaking
			transform.origin = initial_transform.origin
			
			## We're no longer shaking
			is_shaking = false
