class_name UI
extends CanvasLayer

@onready var hurt_vignette: Panel = %HurtVignette

const TIME_FOR_HURT_VIGNETTE_ANIMATION: float = 0.1 ## 100ms

func _ready() -> void:
	## Connect the player_hurt signal
	GameEvents.player_hurt.connect(on_player_hurt)
	
## Make the vignette appear and disappear briefly	
func on_player_hurt(_player: Player) -> void:
	## TWEEN
	var tween := create_tween()
	
	## First bring the alpha of the hurt vignette to 1.0 (fully visible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms 
	tween.tween_property(hurt_vignette, "modulate:a", 1.0, TIME_FOR_HURT_VIGNETTE_ANIMATION)
	## Then make it invisible again, setting alpha back to 0.0 (fully INvisible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms
	tween.tween_property(hurt_vignette, "modulate:a", 0.0, TIME_FOR_HURT_VIGNETTE_ANIMATION)
