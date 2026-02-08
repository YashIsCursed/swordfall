# GameWorld.gd - Main game scene controller
extends Node3D

@onready var world_manager: World_Manager = $WorldManager if has_node("WorldManager") else null
@onready var hud: Control = $CanvasLayer/HUD if has_node("CanvasLayer/HUD") else null
@onready var pause_menu: Control = $CanvasLayer/PauseMenu if has_node("CanvasLayer/PauseMenu") else null

func _ready() -> void:
	add_to_group("game_world")
	
	# Connect world manager signals
	if world_manager:
		world_manager.add_to_group("world_manager")
		world_manager.game_started.connect(_on_game_started)
		world_manager.game_paused.connect(_on_game_paused)
		world_manager.game_resumed.connect(_on_game_resumed)
		world_manager.player_died.connect(_on_player_died)
		world_manager.player_respawned.connect(_on_player_respawned)
		
		# Start the game
		world_manager.start_game()
	
	# Connect pause menu signals
	if pause_menu:
		pause_menu.resumed.connect(_on_pause_resumed)
		pause_menu.hide()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()

func _toggle_pause() -> void:
	if world_manager:
		world_manager.toggle_pause()

func _on_game_started() -> void:
	print("Game started!")
	if hud and world_manager and world_manager.current_player:
		hud.setup_player(world_manager.current_player)
		
		var level = world_manager.level_manager.get_current_level()
		if level:
			hud.update_level(level.level_name, level.level_index)

func _on_game_paused() -> void:
	if pause_menu:
		pause_menu.show_pause_menu()

func _on_game_resumed() -> void:
	if pause_menu:
		pause_menu.hide_pause_menu()

func _on_pause_resumed() -> void:
	if world_manager:
		world_manager.resume_game()

func _on_player_died() -> void:
	if hud:
		hud.show_death_screen()

func _on_player_respawned() -> void:
	if hud:
		hud.hide_death_screen()
