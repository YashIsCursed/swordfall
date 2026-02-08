# HUD.gd - In-game heads-up display
extends Control

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/HealthBar if has_node("MarginContainer/VBoxContainer/TopRow/HealthBar") else null
@onready var health_label: Label = $MarginContainer/VBoxContainer/TopRow/HealthLabel if has_node("MarginContainer/VBoxContainer/TopRow/HealthLabel") else null
@onready var level_label: Label = $MarginContainer/VBoxContainer/TopRow/LevelLabel if has_node("MarginContainer/VBoxContainer/TopRow/LevelLabel") else null
@onready var crosshair: Label = $Crosshair if has_node("Crosshair") else null
@onready var interaction_prompt: Label = $InteractionPrompt if has_node("InteractionPrompt") else null
@onready var death_overlay: ColorRect = $DeathOverlay if has_node("DeathOverlay") else null
@onready var respawn_label: Label = $DeathOverlay/RespawnLabel if has_node("DeathOverlay/RespawnLabel") else null

var player_ref: player = null

func _ready() -> void:
	if death_overlay:
		death_overlay.visible = false
	if interaction_prompt:
		interaction_prompt.visible = false

func setup_player(p: player) -> void:
	player_ref = p
	
	if player_ref and player_ref.props:
		# Connect to health updates
		player_ref.props.update_health.connect(_on_health_updated)
		player_ref.on_death.connect(_on_player_death)
		
		# Initial update
		_update_health_display(player_ref.props.Health, player_ref.props.MaxHealth)

func _on_health_updated(current: float, maximum: float) -> void:
	_update_health_display(current, maximum)

func _update_health_display(current: float, maximum: float) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	
	if health_label:
		health_label.text = str(int(current)) + " / " + str(int(maximum))

func update_level(level_name: String, level_index: int) -> void:
	if level_label:
		level_label.text = "Level " + str(level_index + 1) + ": " + level_name

func show_interaction_prompt(text: String) -> void:
	if interaction_prompt:
		interaction_prompt.text = "[E] " + text
		interaction_prompt.visible = true

func hide_interaction_prompt() -> void:
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_player_death() -> void:
	show_death_screen()

func show_death_screen() -> void:
	if death_overlay:
		death_overlay.visible = true
		death_overlay.modulate.a = 0
		
		var tween = create_tween()
		tween.tween_property(death_overlay, "modulate:a", 0.8, 0.5)
		
		if respawn_label:
			respawn_label.text = "You Died\nRespawning..."

func hide_death_screen() -> void:
	if death_overlay:
		var tween = create_tween()
		tween.tween_property(death_overlay, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): death_overlay.visible = false)
