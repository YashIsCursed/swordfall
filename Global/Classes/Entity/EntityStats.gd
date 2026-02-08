# EntityStats.gd - Resource class for entity statistics
extends Resource
class_name E_Stats

signal update_health(current: float, maximum: float)
signal update_Name()
signal dead
signal update_inventory(item: Item, quantity: int)

@export_category("Entity Props")
@export var MaxHealth: int = 16
@export var ETId: int
@export var Inv: Inventory
@export var Weight: float = 2.0
@export var JumpForce: float = 15.0
@export var MoveSpeed: float = 5.0
@export var Name: String = "Entity"

var _health: float = -1

var Health: float:
	get:
		if _health < 0:
			_health = MaxHealth
		return _health
	set(value):
		_health = clamp(value, 0, MaxHealth)
		update_health.emit(_health, MaxHealth)
		if _health <= 0:
			dead.emit()

func _init() -> void:
	_health = MaxHealth

func reset_health() -> void:
	_health = MaxHealth
	update_health.emit(_health, MaxHealth)

func take_damage(amount: int) -> void:
	Health -= amount

func heal(amount: int) -> void:
	Health = min(Health + amount, MaxHealth)

func is_alive() -> bool:
	return Health > 0
