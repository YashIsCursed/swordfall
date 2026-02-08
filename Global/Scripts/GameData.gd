# GameData.gd - Autoload singleton for managing game state and player settings
extends Node

signal settings_changed
signal world_created(world_name: String)
signal world_loaded(world_name: String)

# Player Settings
var player_name: String = "Player"
var mouse_sensitivity: float = 0.005
var field_of_view: float = 75.0
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0

# Current Game State
var current_world_name: String = ""
var current_level_index: int = 0
var last_checkpoint_position: Vector3 = Vector3.ZERO
var last_checkpoint_level: int = 0
var is_multiplayer: bool = false
var is_host: bool = false

# World saves directory
const SAVES_DIR := "user://saves/"

func _ready() -> void:
	_ensure_saves_directory()
	load_settings()

func _ensure_saves_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")

# Settings Management
func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "name", player_name)
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("graphics", "fov", field_of_view)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://settings.cfg")
	settings_changed.emit()

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		player_name = config.get_value("player", "name", "Player")
		mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", 0.005)
		field_of_view = config.get_value("graphics", "fov", 75.0)
		master_volume = config.get_value("audio", "master_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 0.8)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)

# World Save/Load Management
func get_all_worlds() -> Array[String]:
	var worlds: Array[String] = []
	var dir = DirAccess.open(SAVES_DIR)
	if dir:
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		while folder_name != "":
			if dir.current_is_dir() and folder_name != "." and folder_name != "..":
				worlds.append(folder_name)
			folder_name = dir.get_next()
		dir.list_dir_end()
	return worlds

func create_world(world_name: String) -> bool:
	var world_path = SAVES_DIR + world_name + "/"
	var dir = DirAccess.open("user://")
	if dir:
		var saves_dir = DirAccess.open(SAVES_DIR)
		if saves_dir and saves_dir.dir_exists(world_name):
			return false # World already exists
		saves_dir.make_dir(world_name)
		
		# Create initial world data
		var world_data = {
			"world_name": world_name,
			"created_at": Time.get_datetime_string_from_system(),
			"current_level": 0,
			"checkpoint_position": {"x": 0, "y": 0, "z": 0},
			"checkpoint_level": 0,
			"playtime_seconds": 0
		}
		save_world_data(world_name, world_data)
		world_created.emit(world_name)
		return true
	return false

func save_world_data(world_name: String, data: Dictionary) -> void:
	var file = FileAccess.open(SAVES_DIR + world_name + "/world_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_world_data(world_name: String) -> Dictionary:
	var file_path = SAVES_DIR + world_name + "/world_data.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var parse_result = json.parse(file.get_as_text())
			file.close()
			if parse_result == OK:
				return json.data
	return {}

func delete_world(world_name: String) -> bool:
	var world_path = SAVES_DIR + world_name + "/"
	var dir = DirAccess.open(world_path)
	if dir:
		# Delete all files in the world folder
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		
		# Remove the directory
		var saves_dir = DirAccess.open(SAVES_DIR)
		if saves_dir:
			saves_dir.remove(world_name)
			return true
	return false

func set_current_world(world_name: String) -> void:
	current_world_name = world_name
	var data = load_world_data(world_name)
	if not data.is_empty():
		current_level_index = data.get("current_level", 0)
		var cp = data.get("checkpoint_position", {"x": 0, "y": 0, "z": 0})
		last_checkpoint_position = Vector3(cp.get("x", 0), cp.get("y", 0), cp.get("z", 0))
		last_checkpoint_level = data.get("checkpoint_level", 0)
	world_loaded.emit(world_name)

func save_current_world() -> void:
	if current_world_name.is_empty():
		return
	
	var data = {
		"world_name": current_world_name,
		"created_at": Time.get_datetime_string_from_system(),
		"current_level": current_level_index,
		"checkpoint_position": {
			"x": last_checkpoint_position.x,
			"y": last_checkpoint_position.y,
			"z": last_checkpoint_position.z
		},
		"checkpoint_level": last_checkpoint_level,
		"playtime_seconds": 0
	}
	save_world_data(current_world_name, data)

func update_checkpoint(position: Vector3, level_index: int) -> void:
	last_checkpoint_position = position
	last_checkpoint_level = level_index
	save_current_world()

func reset_game_state() -> void:
	current_world_name = ""
	current_level_index = 0
	last_checkpoint_position = Vector3.ZERO
	last_checkpoint_level = 0
	is_multiplayer = false
	is_host = false
