# World.gd - Base world container class
extends Node3D
class_name World

@export_category("World_Data")
@export var world_name: String = "Unnamed World"
@export var world_id: int = 0

# Legacy compatibility
var Name: String:
	get:
		return world_name
	set(value):
		world_name = value

var levels: Array[Level] = []
var current_level_index: int = 0

func _ready() -> void:
	# Find all levels in this world
	_find_levels()

func _find_levels() -> void:
	levels.clear()
	for child in get_children():
		if child is Level:
			levels.append(child)
	
	# Sort by level index
	levels.sort_custom(func(a, b): return a.level_index < b.level_index)

func get_level(index: int) -> Level:
	if index >= 0 and index < levels.size():
		return levels[index]
	return null

func get_level_count() -> int:
	return levels.size()

func get_current_level() -> Level:
	return get_level(current_level_index)

func set_current_level(index: int) -> void:
	if index >= 0 and index < levels.size():
		# Deactivate old level
		var old_level = get_current_level()
		if old_level:
			old_level.deactivate()
		
		# Activate new level
		current_level_index = index
		var new_level = get_current_level()
		if new_level:
			new_level.activate()
