# SceneManager.gd - Autoload singleton for managing scene transitions
extends Node

signal scene_loading_started(scene_path: String)
signal scene_loading_progress(progress: float)
signal scene_loading_finished(scene_path: String)
signal transition_started
signal transition_finished

# Scene paths
const MAIN_MENU_SCENE := "res://Scenes/UI/MainMenu.tscn"
const SINGLEPLAYER_MENU_SCENE := "res://Scenes/UI/SinglePlayerMenu.tscn"
const MULTIPLAYER_MENU_SCENE := "res://Scenes/UI/MultiplayerMenu.tscn"
const SETTINGS_MENU_SCENE := "res://Scenes/UI/SettingsMenu.tscn"
const GAME_SCENE := "res://Scenes/Game/GameWorld.tscn"

var _loading_screen: Control = null
var _loading_progress: float = 0.0
var _target_scene_path: String = ""
var _is_transitioning: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Simple scene change (no loading screen needed for small scenes)
func change_scene(scene_path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	transition_started.emit()
	
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file(scene_path)
	
	# Wait a frame for scene to change
	await tree.process_frame
	_is_transitioning = false
	transition_finished.emit()

# Async scene loading for larger scenes
func change_scene_async(scene_path: String) -> void:
	if _is_transitioning:
		return
	
	_is_transitioning = true
	_target_scene_path = scene_path
	scene_loading_started.emit(scene_path)
	transition_started.emit()
	
	ResourceLoader.load_threaded_request(scene_path)
	
	while true:
		var progress: Array = []
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_loading_progress = progress[0]
			scene_loading_progress.emit(_loading_progress)
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed_scene = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(packed_scene)
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: " + scene_path)
			break
		
		await get_tree().process_frame
	
	_is_transitioning = false
	scene_loading_finished.emit(scene_path)
	transition_finished.emit()

# Go to main menu
func go_to_main_menu() -> void:
	GameData.reset_game_state()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	change_scene(MAIN_MENU_SCENE)

# Go to SinglePlayer menu
func go_to_singleplayer_menu() -> void:
	change_scene(SINGLEPLAYER_MENU_SCENE)

# Go to Multiplayer menu
func go_to_multiplayer_menu() -> void:
	change_scene(MULTIPLAYER_MENU_SCENE)

# Go to Settings menu
func go_to_settings_menu() -> void:
	change_scene(SETTINGS_MENU_SCENE)

# Start the game with a world
func start_game(world_name: String) -> void:
	GameData.set_current_world(world_name)
	GameData.is_multiplayer = false
	change_scene_async(GAME_SCENE)

# Start multiplayer game
func start_multiplayer_game() -> void:
	GameData.is_multiplayer = true
	change_scene_async(GAME_SCENE)

# Quit the game
func quit_game() -> void:
	get_tree().quit()
