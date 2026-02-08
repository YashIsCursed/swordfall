# Hitbox.gd - Area that deals damage to hurtboxes
extends Area3D
class_name Hitbox

signal hit_landed(target: Node3D)

@export var damage: int = 2
@export var knockback_force: float = 5.0

var is_active: bool = false

func _init() -> void:
	monitorable = true
	monitoring = false
	collision_layer = 4
	collision_mask = 0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func activate() -> void:
	is_active = true
	monitoring = true

func deactivate() -> void:
	is_active = false
	monitoring = false

func _on_area_entered(area: Area3D) -> void:
	if is_active and area is Hurtbox:
		hit_landed.emit(area.get_parent())
