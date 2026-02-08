# SpawnPoint.gd - Spawn point marker for player spawning
extends Marker3D
class_name SpawnPoint

@export_category("SpawnPoint Settings")
@export var is_active: bool = true
@export var spawn_direction: float = 0.0 # Y rotation in degrees

func _ready() -> void:
	# Visual indicator in editor only
	if Engine.is_editor_hint():
		_create_editor_visual()

func _create_editor_visual() -> void:
	var mesh = MeshInstance3D.new()
	var arrow = CylinderMesh.new()
	arrow.top_radius = 0
	arrow.bottom_radius = 0.3
	arrow.height = 1.0
	mesh.mesh = arrow
	mesh.rotation_degrees.x = 90
	mesh.position.z = -0.5
	add_child(mesh)

func get_spawn_position() -> Vector3:
	return global_position + Vector3(0, 1.5, 0)

func get_spawn_rotation() -> Vector3:
	return Vector3(0, spawn_direction, 0)

func spawn_entity(entity: Entity) -> void:
	if entity:
		entity.global_position = get_spawn_position()
		entity.rotation_degrees.y = spawn_direction
