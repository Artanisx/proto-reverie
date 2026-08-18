extends Node3D

## Audio Manager
##
## This is a Global node accesible to all the game and being a node the inspector allows us to set it easily in editor. 
## Takes care of playing all sounds that are invoked through code.

@export var sound_files : Array[AudioStream] = [] ## All sounds imported from the file system into the inspector are available

var cached_sfx : Dictionary[String, AudioStream] = {} ## Maps each audiostream as a string

func _ready() -> void:
	## Populate the dictionary with the sound effects names
	for stream in sound_files:
		## Takes the filename of each string (minus the extension)
		var filename : String = stream.resource_path.get_file().get_basename()
		## Save it as the string key for the stream
		cached_sfx[filename] = stream ## i.e. ["barrel-destroy", 0]

## Plays a sound effect[br]Takes a string filename, and an audiostreamplayer to play from 
func play(filename: String, audio_player:AudioStreamPlayer3D) -> void:
	if cached_sfx.has(filename):
		audio_player.stream = cached_sfx[filename]
		audio_player.pitch_scale = randf_range(0.85,1.15) ## Add a small random pitch to provide variations
		audio_player.play()
	else:
		push_error("Audio filename not found. Please check spelling: ", filename)
		
