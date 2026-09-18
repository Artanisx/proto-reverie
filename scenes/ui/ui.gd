class_name UI
extends CanvasLayer

@onready var hurt_vignette: Panel = %HurtVignette
@onready var heal_vignette: Panel = %HealVignette
@onready var death_screen: ColorRect = %DeathScreen
@onready var victory_screen: ColorRect = %VictoryScreen
@onready var totalkills: Label = %TOTALKILLS
@onready var level: Label = %LEVEL
@onready var runtime: Label = %RUNTIME


@onready var health_indicator: StatIndicator = %HealthIndicator
@onready var weapon_indicator: StatIndicator = %WeaponIndicator
@onready var weapon_icon: TextureRect = %WeaponIcon
@onready var shield_icon: TextureRect = %ShieldIcon
@onready var shield_indicator: StatIndicator = %ShieldIndicator
@onready var exp_indicator: StatIndicator = $ExpIndicator
@onready var level_indicator: NumberIndicator = $LevelIndicator
@onready var strength_indicator: NumberIndicator = $StrengthIndicator

@onready var action_panel: ColorRect = %ActionPanel
@onready var action_label: Label = %ActionLabel
@onready var message_panel: ColorRect = %MessagePanel
@onready var message_label: Label = $MessagePanel/MessageLabel


@onready var key_container: HBoxContainer = %KeyContainer
@onready var minimap_camera: MinimapCamera = $MinimapPanel/Minimap/SubViewport/MinimapCamera

const TIME_FOR_HURT_VIGNETTE_ANIMATION: float = 0.1 ## 100ms
const TIME_FOR_HEAL_VIGNETTE_ANIMATION: float = 0.1 ## 100ms
const TIME_FOR_DEATH_SCREEN_ANIMATION: float = 0.3 ## 300ms
const TIME_FOR_VICTORY_SCREEN_ANIMATION: float = 0.3 ## 300ms
const TIME_UI_MESSAGE_FADETOUT_TIME: float = 2.0 ## 300ms


const UI_STRING_KEY_PICKED_UP_PART_1 : String = "You picked up a "
const UI_STRING_KEY_PICKED_UP_PART_2 : String = " key!"
const UI_STRING_KEY_COLOR_BLUE: String = "Blue"
const UI_STRING_KEY_COLOR_RED: String = "Red"
const UI_STRING_KEY_COLOR_YELLOW: String = "Yellow"
const UI_STRING_KEY_COLOR_PURPLE: String = "Purple"
const UI_STR_NAME: String = "POWER"

const KEY_TEXTURE_PREFAB := preload("res://scenes/ui/key_texture.tscn")

func _ready() -> void:
	## Connect the player_hurt signal
	GameEvents.player_hurt.connect(on_player_hurt)
	
	## Connect the player_hurt signal
	GameEvents.player_healed.connect(on_player_healed)
	
	## Connect the player_dead signal
	GameEvents.player_dead.connect(on_player_dead)
	
	## Connect the boss_dead signal
	GameEvents.boss_dead.connect(on_boss_dead)
	
	## Connect the signal for restart (so we can hide the death screen)
	GameEvents.level_restarted.connect(on_level_restarted)
	
	## Connec tthe harder rtestart with the same callback
	GameEvents.level_harder_restarted.connect(on_level_harder_restarted)
	
	## Connect the signal for when the player spawns in the world
	GameEvents.player_spawned.connect(on_player_spawned)	
	
	## Connect the signal for when the player equipped Weapon has something aobut it changed (durability/being equipped/dropped/thrown...)
	GameEvents.weapon_changed.connect(on_weapon_changed)	
	
	## Connect the signal for when the player equipped Shield has something aobut it changed (durability/being equipped/dropped/thrown...)
	GameEvents.shield_changed.connect(on_shield_changed)	
	
	## Connect the signal for when the player can take a new action (selected a pickable item, a door in kick range...)
	GameEvents.possible_action_changed.connect(on_possible_action_changed)	
	
	## Connect to the key_picked_up event signal for when the player picks up the key / use a key / loses a key
	GameEvents.current_keys_changed.connect(on_current_keys_changed)
	
	## Connect to the key_picked_up event signal for when the player picks up the key
	GameEvents.obtained_key.connect(on_picked_up_key)
	
	## Connect to the exp_up event signal for when player gains exp
	GameEvents.exp_up.connect(on_exp_up)
	
	## Cooonec tto the level_up event signal for when the player gains a level
	GameEvents.level_up.connect(on_level_up)
	
	
## Make the vignette appear and disappear briefly	
func on_player_hurt(player: Player) -> void:
	## TWEEN
	var tween := create_tween()
	
	## First bring the alpha of the hurt vignette to 1.0 (fully visible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms 
	tween.tween_property(hurt_vignette, "modulate:a", 1.0, TIME_FOR_HURT_VIGNETTE_ANIMATION)
	## Then make it invisible again, setting alpha back to 0.0 (fully INvisible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms
	tween.tween_property(hurt_vignette, "modulate:a", 0.0, TIME_FOR_HURT_VIGNETTE_ANIMATION)
	## Finally, update the HP bar
	health_indicator.refresh(player.health.current_life, player.health.max_life)
	
	
## Make the vignette appear and disappear briefly	
func on_player_healed(player: Player) -> void:
	## TWEEN
	var tween := create_tween()
	
	## First bring the alpha of the heal vignette to 1.0 (fully visible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms 
	tween.tween_property(heal_vignette, "modulate:a", 1.0, TIME_FOR_HEAL_VIGNETTE_ANIMATION)
	## Then make it invisible again, setting alpha back to 0.0 (fully INvisible) in TIME_FOR_HURT_VIGNETTE_ANIMATION ms
	tween.tween_property(heal_vignette, "modulate:a", 0.0, TIME_FOR_HEAL_VIGNETTE_ANIMATION)
	## Finally, update the HP bar
	health_indicator.refresh(player.health.current_life, player.health.max_life)	
	
## Make the DeathScreen appear
func on_player_dead() -> void:
	## TWEEN
	var tween := create_tween()
	
	## Let's modulate everything back to white (this basically just move the alpha 1.0 (fully visible), keeping the rgs back as white)
	#  in TIME_FOR_DEATH_SCREEN_ANIMATION ms, with a set transition and ease
	tween.tween_property(death_screen, "modulate", Color.WHITE, TIME_FOR_DEATH_SCREEN_ANIMATION)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

## Make the DeathScreen appear WARNING NYI		 
func on_boss_dead() -> void:
	## CALCULATE STATS	
	var duration_since_gamestart := Time.get_ticks_msec() - GameState.run_time_from_start 
	var time_passed = duration_since_gamestart / 1000
	GameState.end_time = time_convert(time_passed)
	runtime.text = "RUN TIME: " + GameState.end_time
	totalkills.text = "TOTAL KILL(S): " + str(GameState.number_of_kills)
	level.text = "LEVEL REACHED: " + str(GameState.current_player.experience.current_level)	
	
	## TWEEN
	var tween := create_tween()
	
	## Let's modulate everything back to white (this basically just move the alpha 1.0 (fully visible), keeping the rgs back as white)
	#  in TIME_FOR_VICTORY_SCREEN_ANIMATION ms, with a set transition and ease
	tween.tween_property(victory_screen, "modulate", Color.WHITE, TIME_FOR_VICTORY_SCREEN_ANIMATION)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)


## Convert secocds in HH:MM:SS format	
func time_convert(time_in_sec: int) -> String:
	var seconds = time_in_sec%60
	var minutes = time_in_sec/60
	var hours = minutes/60

	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d" % [hours, minutes - (60 * hours), seconds - (60 * minutes)]
		
## Make the DeathScreen disappear
func on_level_restarted() -> void:	
	## Let's modulate this back to transparent instantly
	death_screen.modulate = Color.TRANSPARENT
	victory_screen.modulate = Color.TRANSPARENT
	## Set the playstate
	GameState.current_game_state = GameState.PlayState.PLAYING
	
func on_level_harder_restarted(_level_size: Vector2i, _cp_length: int, _branches: int, _branch_length: Vector2i) -> void:
	## Let's modulate this back to transparent instantly
	death_screen.modulate = Color.TRANSPARENT
	victory_screen.modulate = Color.TRANSPARENT
	## Set the playstate
	GameState.current_game_state = GameState.PlayState.PLAYING
	
## Player just spawned, refresh HealthIndicator
func on_player_spawned(player: Player) -> void:
	health_indicator.refresh(player.health.current_life, player.health.max_life)
	## we update the weapon bar UI (so if the player doesn't start with the weapon the Ui is correct)
	on_weapon_changed(player.equipment.weapon_data)
	## we update the shield bar UI (so if the player doesn't start with the shield the Ui is correct)
	on_shield_changed(player.equipment.shield_data)
	## We update the XP bar UI
	on_exp_up(player) 
	##We udpoat ethe elevel text ui
	on_level_up()
	## Set the minimap camera offset based on player start global position
	minimap_camera.set_offset(GameState.current_player.global_position)	

## Something about the players' weapon changed and we need to update the ui
func on_weapon_changed(data: WeaponData) -> void:
	if data == null:
		## Weapon was thrown/dropped and otherwise lost
		weapon_icon.visible = false
		weapon_indicator.set_visible(false)
	else:
		## Weapon had its durability changed or was just equipped
		if weapon_icon.visible == false or weapon_indicator.visible == false:
			weapon_icon.visible = true # Make sure the weapon_icon is now visible
			weapon_indicator.set_visible(true) # Same with the indicator
		## refresh the durability
		weapon_indicator.refresh(data.condition, data.max_condition)

## Something about the players' shield changed and we need to update the ui
func on_shield_changed(data: ShieldData) -> void:
	if data == null:
		## Shield was thrown/dropped and otherwise lost
		shield_icon.visible = false
		shield_indicator.set_visible(false)
	else:
		## shield had its durability changed or was just equipped
		if shield_icon.visible == false or shield_indicator.visible == false:
			shield_icon.visible = true # Make sure the weapon_icon is now visible
			shield_indicator.set_visible(true) # Same with the indicator
		## refresh the durability
		shield_indicator.refresh(data.condition, data.max_condition)

## Update the ActionPanel accordingly		
func on_possible_action_changed(action: String) -> void:
	## Toggle action panel visiblity to wheter the action is empty or not
	action_panel.visible = not action.is_empty()
	action_label.text = action		
	
## Update the KeyContainer accordingly each time there's a key change in the inventory	
func on_current_keys_changed(_color: Door.KeyColor) -> void:
	## Clear all key containers 
	if key_container.get_child_count() > 0:
		for keytexture in key_container.get_children():
			keytexture.queue_free()	
	
	## Loop through all the values of the Door.KeyColor enum
	for key_color: Door.KeyColor in Door.KeyColor.values():
		## check if the player has this keycolor key
		if GameState.has_key(key_color):
			var key_texture: TextureRect = KEY_TEXTURE_PREFAB.instantiate() as TextureRect
			key_texture.modulate = Door.COLOR_MAP[key_color]
				
			key_container.add_child(key_texture)
			


## SHow a message
func on_picked_up_key(color: Door.KeyColor) -> void:
	var str_color : String = ""
	
	match color:
				Door.KeyColor.Blue:			
					str_color = UI_STRING_KEY_COLOR_BLUE
				Door.KeyColor.Red:			
					str_color = UI_STRING_KEY_COLOR_RED
				Door.KeyColor.Yellow:			
					str_color = UI_STRING_KEY_COLOR_YELLOW
				Door.KeyColor.Purple:			
					str_color = UI_STRING_KEY_COLOR_PURPLE
	
	## We need to briefly show a message to the player	
	show_message(UI_STRING_KEY_PICKED_UP_PART_1 + str_color + UI_STRING_KEY_PICKED_UP_PART_2)	

## Show a text message in the screen for a set time.
## If timeout time is not set, the default is assumed
func show_message(message: String, timeout: float = TIME_UI_MESSAGE_FADETOUT_TIME) -> void:
	message_panel.visible = true
	message_label.text = message
	
	## Start a timer to make the message vanish
	var timer := get_tree().create_timer(timeout)	## Create atimer of the set duration
	timer.timeout.connect(on_message_fadeout.bind(message_panel))						## Set its callback rto the timeout signal

## Makes the passed ColorRect panel invisible
func on_message_fadeout(panel: ColorRect) -> void:
	panel.visible = false	

## Player gained experience, so it must refresh the exp indicator
func on_exp_up(player: Player) -> void:
	## refresh the exp indicator
	exp_indicator.refresh(player.experience.current_exp, player.experience.max_exp)
	
func on_level_up() -> void:
	## On a level up several stast update. We need to refresh them all here.
	## refreshes the LevelIndicator
	level_indicator.refresh(GameState.current_player.experience.current_level, GameState.current_player.experience.max_level, "LEVEL: ")
	##refreshes the HelathINdicator
	health_indicator.refresh(GameState.current_player.health.current_life, GameState.current_player.health.max_life)
	## refreshe the strethindicator
	strength_indicator.refresh(GameState.current_player.player_strength, -1, UI_STR_NAME + " : ")
