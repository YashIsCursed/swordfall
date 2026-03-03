# Entity.gd - Base class for all entities (Player, Mob, etc.)
extends CharacterBody3D
class_name Entity

signal on_damage_taken(amount: int)
signal on_death

@onready var hurtbox: Hurtbox = $Hurtbox if has_node("Hurtbox") else null
@onready var hitbox: Hitbox = $Hitbox if has_node("Hitbox") else null
@onready var item_in_hand: Item = $Item if has_node("Item") else null
@onready var mesh: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else null

@export_category("Details")
@export var props: E_Stats

var is_dead: bool = false
var is_attacking: bool = false

func _ready() -> void:
	# CRITICAL: Duplicate the props resource so each entity has its own stats
	# Without this, all instances share the same health pool!
	if props:
		props = props.duplicate()
	else:
		props = E_Stats.new()
		props.Name = "Entity"
		props.ETId = randi()
	
	# Reset health to max for this new instance
	props.reset_health()
	
	# Connect hurtbox damage signal
	if hurtbox:
		hurtbox.DamageTaken.connect(_on_hurtbox_damage_taken)
	
	# Connect death signal
	if props:
		props.dead.connect(_on_entity_death)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= (9.8 + int(props.Weight / 2)) * delta

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	if props:
		props.Health -= amount
	
	on_damage_taken.emit(amount)

func _on_hurtbox_damage_taken(amount: int) -> void:
	take_damage(amount)

func _on_entity_death() -> void:
	if is_dead:
		return
	
	is_dead = true
	print(props.Name + " died!")
	on_death.emit()
	_on_death()

func _on_death() -> void:
	# Override in child classes for custom death behavior
	queue_free()

func heal(amount: int) -> void:
	if props:
		props.Health = min(props.Health + amount, props.MaxHealth)

func jump(force: float = 10.0) -> void:
	if is_on_floor():
		velocity.y = force

func attack() -> void:
	if is_attacking or is_dead:
		return
	
	is_attacking = true
	
	# Enable hitbox during attack
	if hitbox:
		hitbox.set_deferred("monitoring", true)
	
	# Attack duration
	await get_tree().create_timer(0.3).timeout
	
	# Disable hitbox after attack
	if hitbox:
		hitbox.set_deferred("monitoring", false)
	
	is_attacking = false

func get_forward_direction() -> Vector3:
	return -transform.basis.z.normalized()

func look_at_target(target_position: Vector3) -> void:
	var look_pos = target_position
	look_pos.y = global_position.y # Keep horizontal
	look_at(look_pos)
