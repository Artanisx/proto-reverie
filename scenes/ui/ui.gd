class_name UI
extends CanvasLayer

@onready var hurt_vignette: Panel = %HurtVignette
@onready var death_screen: ColorRect = %DeathScreen


const TIME_FOR_HURT_VIGNETTE_ANIMATION: float = 0.1 ## 100ms
const TIME_FOR_DEATH_SCREEN_ANIMATION: float = 0.3 ## 100ms

func _ready() -> void:
	## Connect the player_hurt signal
	GameEvents.player_hurt.connect(on_player_hurt)
	
	## Connect the player_dead signal
	GameEvents.player_dead.connect(on_player_dead)
	
	## Connect the signal for restart (so we can hide the death screen)
	GameEvents.level_restarted.connect(on_level_restarted)
	
## Make the vignette appear and disappear briefly	
func on_player_hurt(_player: Player) -> void:
	## TWEEN
	var tween := create_tween()
	
	## First bring the alpha of the hurt vignette to 1.0 (fully visible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms 
	tween.tween_property(hurt_vignette, "modulate:a", 1.0, TIME_FOR_HURT_VIGNETTE_ANIMATION)
	## Then make it invisible again, setting alpha back to 0.0 (fully INvisible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms
	tween.tween_property(hurt_vignette, "modulate:a", 0.0, TIME_FOR_HURT_VIGNETTE_ANIMATION)
	
## Make the DeathScreen appear
func on_player_dead() -> void:
	## TWEEN
	var tween := create_tween()
	
	## Let's modulate everything back to white (this basically just move the alpha 1.0 (fully visible), keeping the rgs back as white)
	#  in TIME_FOR_DEATH_SCREEN_ANIMATION ms, with a set transition and ease
	tween.tween_property(death_screen, "modulate", Color.WHITE, TIME_FOR_DEATH_SCREEN_ANIMATION)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		
## Make the DeathScreen disappear
func on_level_restarted() -> void:	
	## Let's modulate this back to transparent instantly
	death_screen.modulate = Color.TRANSPARENT
		
