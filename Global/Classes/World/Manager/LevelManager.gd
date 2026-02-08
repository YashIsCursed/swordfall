# LevelManager.gd - Manages level loading, transitions, and current level state
extends Node3D
class_name LevelManager

signal level_loading_started(level_index: int)
signal level_loading_finished(level_index: int)
signal level_changed(from_index: int, to_index: int)
signal all_levels_completed

@export_category("Level Configuration")
@export var levels: Array[PackedScene] = []
@export var start_level_index: int = 0

var current_level: Level = null
var current_level_index: int = -1
var _levels_container: Node3D
var _is_loading: bool = false

func _ready() -> void:
	_levels_container = Node3D.new()
	_levels_container.name = "LevelsContainer"
	add_child(_levels_container)

func initialize_levels(level_scenes: Array[PackedScene]) -> void:
	levels = level_scenes

func load_level(index: int) -> void:
	if _is_loading:
		return
	
	if index < 0 or index >= levels.size():
		push_error("Invalid level index: " + str(index))
		return
	
	_is_loading = true
	level_loading_started.emit(index)
	
	var old_index = current_level_index
	
	# Unload current level
	if current_level:
		current_level.deactivate()
		current_level.queue_free()
		current_level = null
	
	# Load new level
	var level_scene = levels[index]
	if level_scene:
		var level_instance = level_scene.instantiate()
		_levels_container.add_child(level_instance)
		
		if level_instance is Level:
			current_level = level_instance
			current_level.level_index = index
			current_level.level_completed.connect(_on_level_completed)
			current_level.activate()
		else:
			# Wrap in a basic Level node if not already a Level
			var level_wrapper = Level.new()
			level_wrapper.name = "Level_" + str(index)
			level_wrapper.level_index = index
			level_instance.reparent(level_wrapper)
			_levels_container.add_child(level_wrapper)
			current_level = level_wrapper
			current_level.level_completed.connect(_on_level_completed)
			current_level.activate()
	
	current_level_index = index
	_is_loading = false
	
	level_loading_finished.emit(index)
	level_changed.emit(old_index, index)

func load_next_level() -> void:
	var next_index = current_level_index + 1
	if next_index < levels.size():
		load_level(next_index)
	else:
		all_levels_completed.emit()

func reload_current_level() -> void:
	if current_level_index >= 0:
		load_level(current_level_index)

func get_spawn_position() -> Vector3:
	if current_level:
		return current_level.get_spawn_position()
	return Vector3.ZERO

func get_current_level() -> Level:
	return current_level

func _on_level_completed() -> void:
	print("Level " + str(current_level_index) + " completed!")
	load_next_level()
