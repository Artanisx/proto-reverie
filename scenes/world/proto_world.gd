class_name ProtoWorld
extends Node3D

@onready var minimap_camera: MinimapCamera = $MarginContainer/PanelContainer/Minimap/SubViewport/MinimapCamera

@onready var test_procedural_level: BaseProceduralLevel = $TestProceduralLevel

func _ready() -> void:
	minimap_camera.minimap_ready.connect(on_minimap_ready.bind())
	GameState.register_level(test_procedural_level)	 ## Register the currently loaded level

func on_minimap_ready() -> void:
	##print("received minimap readyness")
	minimap_camera.set_player(test_procedural_level.get_player())
