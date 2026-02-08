# Hurtbox.gd - Area that receives damage from hitboxes
extends Area3D
class_name Hurtbox

signal damage_taken(amount: int)
signal DamageTaken(amount: int) # For backwards compatibility

@export var invincibility_time: float = 0.0
var is_invincible: bool = false

func _init() -> void:
	monitorable = false
	monitoring = true
	collision_layer = 0
	collision_mask = 4

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is Hitbox and not is_invincible:
		take_damage(area.damage)

func take_damage(amount: int) -> void:
	if is_invincible:
		return
	
	damage_taken.emit(amount)
	DamageTaken.emit(amount)
	
	if invincibility_time > 0:
		_start_invincibility()

func _start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false

func set_invincible(value: bool) -> void:
	is_invincible = value
