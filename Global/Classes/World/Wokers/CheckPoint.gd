# CheckPoint.gd - Checkpoint marker that saves player progress
extends Marker3D
class_name CheckPoint

signal checkpoint_activated(checkpoint: CheckPoint)
signal checkpoint_deactivated(checkpoint: CheckPoint)

@export_category("Checkpoint Settings")
@export var checkpoint_number: int = 0
@export var for_respawn: bool = true
@export var auto_activate_on_enter: bool = true

@onready var trigger_area: Area3D = $TriggerArea if has_node("TriggerArea") else null
@onready var visual: MeshInstance3D = $Visual if has_node("Visual") else null

var active: bool = false
var passed: bool = false
var Active: bool:
	get:
		return active
	set(value):
		active = value

func _ready() -> void:
	# Create trigger area if not exists
	if not trigger_area and auto_activate_on_enter:
		_create_trigger_area()
	elif trigger_area:
		trigger_area.body_entered.connect(_on_body_entered)

func _create_trigger_area() -> void:
	trigger_area = Area3D.new()
	trigger_area.name = "TriggerArea"
	trigger_area.monitorable = false
	trigger_area.monitoring = true
	
	# Important: Make sure the area only looks at the player's collision layer (typically layer 2)
	trigger_area.collision_layer = 0
	trigger_area.collision_mask = 2 # Player mask
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(3, 4, 3)
	collision_shape.shape = box_shape
	
	trigger_area.add_child(collision_shape)
	add_child(trigger_area)
	
	trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is player and auto_activate_on_enter:
		activate(body)

func activate(activating_player: player = null) -> void:
	if active:
		return
	
	active = true
	passed = true
	
	# Update visual
	if visual:
		var mat = visual.get_surface_override_material(0)
		if mat:
			mat.albedo_color = Color.GREEN
	
	# Save checkpoint
	if activating_player:
		activating_player.set_last_checkpoint(self )
	
	checkpoint_activated.emit(self )
	print("Checkpoint " + str(checkpoint_number) + " activated!")

func deactivate() -> void:
	active = false
	
	# Update visual
	if visual:
		var mat = visual.get_surface_override_material(0)
		if mat:
			mat.albedo_color = Color.GRAY
	
	checkpoint_deactivated.emit(self )

func teleport_entity(entity: Entity) -> void:
	if entity:
		entity.global_position = global_position + Vector3(0, 1, 0)

func get_spawn_position() -> Vector3:
	return global_position + Vector3(0, 1, 0)
