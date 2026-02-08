# Mobs.gd - Enhanced Mob AI with detection, chasing, wandering, and attacking
extends Entity
class_name Mob

enum MobState {
	IDLE,
	WANDERING,
	CHASING,
	ATTACKING,
	RETURNING
}

@onready var ray: RayCast3D = $RayCast3D if has_node("RayCast3D") else null
@onready var detection_area: Area3D = $DetectionArea if has_node("DetectionArea") else null
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D if has_node("NavigationAgent3D") else null

@export_category("Mob AI Settings")
@export var detection_range: float = 15.0
@export var attack_range: float = 2.5
@export var chase_speed: float = 5.0
@export var wander_speed: float = 2.0
@export var attack_damage: int = 2
@export var attack_cooldown: float = 1.5
@export var ray_rotation_speed: float = 5.0 # Degrees per frame
@export var wander_radius: float = 8.0
@export var wander_wait_time: float = 3.0
@export var is_boss: bool = false

var target: player = null
var current_state: MobState = MobState.IDLE
var spawn_position: Vector3
var can_attack_mob: bool = true
var wander_target: Vector3 = Vector3.ZERO
var ray_current_angle: float = 0.0

func _ready() -> void:
	super._ready()
	spawn_position = global_position
	
	# Set up detection area if it doesn't exist
	if not detection_area:
		_create_detection_area()
	else:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	# Set wander target
	_set_random_wander_target()
	current_state = MobState.WANDERING

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	super._physics_process(delta)
	
	# Rotate detection ray
	_rotate_detection_ray()
	
	# Check ray for player detection
	_check_ray_detection()
	
	# State machine
	match current_state:
		MobState.IDLE:
			_state_idle(delta)
		MobState.WANDERING:
			_state_wandering(delta)
		MobState.CHASING:
			_state_chasing(delta)
		MobState.ATTACKING:
			_state_attacking(delta)
		MobState.RETURNING:
			_state_returning(delta)

func _rotate_detection_ray() -> void:
	if ray:
		ray_current_angle += ray_rotation_speed
		if ray_current_angle >= 360.0:
			ray_current_angle = 0.0
		ray.rotation_degrees.y = ray_current_angle

func _check_ray_detection() -> void:
	if ray and ray.is_colliding():
		var collider = ray.get_collider()
		if collider is player and not collider.is_dead:
			target = collider
			_change_state(MobState.CHASING)

func _state_idle(delta: float) -> void:
	# Wait, then start wandering
	await get_tree().create_timer(wander_wait_time).timeout
	_set_random_wander_target()
	_change_state(MobState.WANDERING)

func _state_wandering(_delta: float) -> void:
	if target:
		_change_state(MobState.CHASING)
		return
	
	# Move toward wander target
	var direction = (wander_target - global_position).normalized()
	direction.y = 0
	
	if direction.length() > 0.1:
		velocity.x = direction.x * wander_speed
		velocity.z = direction.z * wander_speed
		look_at_target(wander_target)
	
	# Check if reached wander target
	var dist_to_target = global_position.distance_to(wander_target)
	if dist_to_target < 1.5:
		velocity.x = 0
		velocity.z = 0
		_change_state(MobState.IDLE)

func _state_chasing(_delta: float) -> void:
	if not target or target.is_dead:
		target = null
		_change_state(MobState.RETURNING)
		return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	
	# Check if lost target (too far)
	if distance_to_target > detection_range * 1.5:
		target = null
		_change_state(MobState.RETURNING)
		return
	
	# Check if in attack range
	if distance_to_target <= attack_range:
		_change_state(MobState.ATTACKING)
		return
	
	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed
	
	look_at_target(target.global_position)

func _state_attacking(_delta: float) -> void:
	if not target or target.is_dead:
		target = null
		_change_state(MobState.RETURNING)
		return
	
	var distance_to_target = global_position.distance_to(target.global_position)
	
	# Check if target moved out of attack range
	if distance_to_target > attack_range * 1.2:
		_change_state(MobState.CHASING)
		return
	
	# Stop moving while attacking
	velocity.x = 0
	velocity.z = 0
	
	look_at_target(target.global_position)
	
	# Attack
	if can_attack_mob:
		_perform_attack()

func _state_returning(_delta: float) -> void:
	# Return to spawn position
	var distance_to_spawn = global_position.distance_to(spawn_position)
	
	if distance_to_spawn < 1.5:
		velocity.x = 0
		velocity.z = 0
		_change_state(MobState.IDLE)
		return
	
	var direction = (spawn_position - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * wander_speed
	velocity.z = direction.z * wander_speed
	
	look_at_target(spawn_position)

func _change_state(new_state: MobState) -> void:
	current_state = new_state

func _set_random_wander_target() -> void:
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)
	wander_target = spawn_position + random_offset
	wander_target.y = global_position.y

func _perform_attack() -> void:
	can_attack_mob = false
	
	# Deal damage to target
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage)
	
	# Attack animation could go here
	attack()
	
	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack_mob = true

func _on_death() -> void:
	is_dead = true
	
	# Play death effect
	if mesh:
		var tween = create_tween()
		tween.tween_property(mesh, "scale", Vector3.ZERO, 0.5)
		tween.tween_callback(queue_free)
	else:
		queue_free()

func _create_detection_area() -> void:
	detection_area = Area3D.new()
	detection_area.name = "DetectionArea"
	
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = detection_range
	collision_shape.shape = sphere_shape
	
	detection_area.add_child(collision_shape)
	add_child(detection_area)
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is player and not body.is_dead:
		target = body
		_change_state(MobState.CHASING)

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body == target:
		# Don't immediately lose target, let distance check handle it
		pass
