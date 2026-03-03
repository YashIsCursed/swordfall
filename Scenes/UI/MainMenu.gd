# MainMenu.gd - Main menu UI controller
extends Control

@onready var logo: TextureRect = $VBoxContainer/Logo if has_node("VBoxContainer/Logo") else null
@onready var btn_singleplayer: Button = $VBoxContainer/BtnSinglePlayer
@onready var btn_multiplayer: Button = $VBoxContainer/BtnMultiplayer
@onready var btn_settings: Button = $VBoxContainer/BtnSettings
@onready var btn_quit: Button = $VBoxContainer/BtnQuit
@onready var version_label: Label = $VersionLabel if has_node("VersionLabel") else null

# Store original positions to reset properly
var _button_original_positions: Dictionary = {}

func _ready() -> void:
	# SAFETY: Ensure tree is unpaused (in case we came from a paused game)
	get_tree().paused = false
	
	# ALWAYS ensure mouse is visible in menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Connect button signals
	btn_singleplayer.pressed.connect(_on_singleplayer_pressed)
	btn_multiplayer.pressed.connect(_on_multiplayer_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	
	# Set version if label exists
	if version_label:
		version_label.text = "v0.1.0 Alpha"
	
	# Store original positions BEFORE animating
	var buttons = [btn_singleplayer, btn_multiplayer, btn_settings, btn_quit]
	for btn in buttons:
		if btn:
			_button_original_positions[btn] = btn.position.x
	
	# Animate buttons on ready
	_animate_menu_in()

func _animate_menu_in() -> void:
	var buttons = [btn_singleplayer, btn_multiplayer, btn_settings, btn_quit]
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		if not btn:
			continue
			
		# Get original position (stored earlier or current)
		var original_x = _button_original_positions.get(btn, btn.position.x)
		
		# Start hidden and offset
		btn.modulate.a = 0
		btn.position.x = original_x - 50
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(btn, "modulate:a", 1.0, 0.3).set_delay(i * 0.1)
		tween.parallel().tween_property(btn, "position:x", original_x, 0.4).set_delay(i * 0.1)

func _on_singleplayer_pressed() -> void:
	_play_button_sound()
	SceneManager.go_to_singleplayer_menu()

func _on_multiplayer_pressed() -> void:
	_play_button_sound()
	SceneManager.go_to_multiplayer_menu()

func _on_settings_pressed() -> void:
	_play_button_sound()
	SceneManager.go_to_settings_menu()

func _on_quit_pressed() -> void:
	_play_button_sound()
	SceneManager.quit_game()

func _play_button_sound() -> void:
	# Add button click sound here if audio manager exists
	pass
