# Level.gd - Represents a single level in the game world
extends Node3D
class_name Level

signal level_completed
signal level_started
signal player_entered_completion_area

@export_category("Level Data")
@export var level_name: String = "Unnamed Level"
@export var level_index: int = 0
@export var level_scene: PackedScene

@export_category("Spawn Configuration")
@export var spawn_point: SpawnPoint
@export var checkpoints: Array[CheckPoint] = []

@export_category("Mob Configuration")
@export var mob_areas: Array[MobArea] = []

@export_category("Completion")
@export var completion_area: CompletionArea

var is_active: bool = false
var is_completed: bool = false

func _ready() -> void:
	# Find spawn point if not set
	if not spawn_point:
		spawn_point = _find_node_of_type("SpawnPoint") as SpawnPoint
	
	# Find checkpoints
	if checkpoints.is_empty():
		for node in _find_all_nodes_of_type("CheckPoint"):
			if node is CheckPoint:
				checkpoints.append(node)
	
	# Find mob areas
	if mob_areas.is_empty():
		for node in _find_all_nodes_of_type("MobArea"):
			if node is MobArea:
				mob_areas.append(node)
	
	# Find completion area
	if not completion_area:
		completion_area = _find_node_of_type("CompletionArea") as CompletionArea
	
	# Connect completion area signal
	if completion_area:
		completion_area.player_entered.connect(_on_completion_area_entered)

func _find_node_of_type(type_name: String) -> Node:
	for child in get_children():
		if child.get_class() == type_name or (child.has_method("get_script") and child.get_script() and child.get_script().get_global_name() == type_name):
			return child
	return null

func _find_all_nodes_of_type(type_name: String) -> Array:
	var nodes: Array = []
	_find_nodes_recursive(self, type_name, nodes)
	return nodes

func _find_nodes_recursive(node: Node, type_name: String, result: Array) -> void:
	for child in node.get_children():
		var script = child.get_script()
		if script and script.get_global_name() == type_name:
			result.append(child)
		_find_nodes_recursive(child, type_name, result)

func activate() -> void:
	is_active = true
	visible = true
	set_process(true)
	set_physics_process(true)
	
	# Activate all mob areas
	for mob_area in mob_areas:
		if mob_area:
			mob_area.activate()
	
	level_started.emit()

func deactivate() -> void:
	is_active = false
	visible = false
	set_process(false)
	set_physics_process(false)
	
	# Deactivate all mob areas
	for mob_area in mob_areas:
		if mob_area:
			mob_area.deactivate()

func get_spawn_position() -> Vector3:
	if spawn_point:
		return spawn_point.global_position
	return Vector3.ZERO

func get_checkpoint(index: int) -> CheckPoint:
	if index >= 0 and index < checkpoints.size():
		return checkpoints[index]
	return null

func get_active_checkpoint() -> CheckPoint:
	for checkpoint in checkpoints:
		if checkpoint and checkpoint.Active:
			return checkpoint
	return null

func _on_completion_area_entered() -> void:
	is_completed = true
	player_entered_completion_area.emit()
	level_completed.emit()
