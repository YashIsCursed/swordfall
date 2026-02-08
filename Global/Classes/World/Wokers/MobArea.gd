# MobArea.gd - Area that spawns mobs when player enters
extends Area3D
class_name MobArea

signal mobs_spawned
signal all_mobs_defeated

@export_category("Mob Area Settings")
@export var mob_scenes: Array[PackedScene] = []
@export var spawn_amount: int = 3
@export var max_mobs_alive: int = 5
@export var spawn_radius: float = 5.0
@export var respawn_delay: float = 10.0
@export var spawn_on_enter: bool = true
@export var one_time_spawn: bool = false

# Default mob scene path - used if mob_scenes is empty
const DEFAULT_MOB_PATH := "res://mob1.tscn"

var is_player_in: bool = false
var spawned_mobs: Array[Node3D] = [] # Changed from Array[Mob] to avoid type issues
var has_spawned: bool = false
var is_active: bool = true

func _init() -> void:
	# Setup collision for detecting player
	collision_layer = 0
	collision_mask = 2 # Player layer

func _ready() -> void:
	body_entered.connect(_on_mob_area_entered)
	body_exited.connect(_on_mob_area_exited)
	
	# Add a collision shape if none exists
	if get_child_count() == 0 or not _has_collision_shape():
		var shape = CollisionShape3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = spawn_radius
		shape.shape = sphere
		add_child(shape)
		print("MobArea: Auto-created collision shape with radius ", spawn_radius)

func _has_collision_shape() -> bool:
	for child in get_children():
		if child is CollisionShape3D:
			return true
	return false

func _on_mob_area_entered(body: Node3D) -> void:
	if body is player and is_active:
		is_player_in = true
		print("MobArea: Player entered!")
		if spawn_on_enter and (not one_time_spawn or not has_spawned):
			spawn_mobs()

func _on_mob_area_exited(body: Node3D) -> void:
	if body is player:
		is_player_in = false
		print("MobArea: Player exited!")

func spawn_mobs() -> void:
	# Load default mob if no mobs configured
	var scenes_to_use = mob_scenes
	if scenes_to_use.is_empty():
		var default_mob = load(DEFAULT_MOB_PATH)
		if default_mob:
			scenes_to_use = [default_mob]
			print("MobArea: Using default mob scene")
		else:
			push_warning("MobArea has no mob scenes and default mob not found!")
			return
	
	var mobs_to_spawn = min(spawn_amount, max_mobs_alive - spawned_mobs.size())
	print("MobArea: Spawning ", mobs_to_spawn, " mobs")
	
	for i in range(mobs_to_spawn):
		var mob_scene = scenes_to_use[randi() % scenes_to_use.size()]
		if mob_scene:
			var mob_instance = mob_scene.instantiate()
			if mob_instance:
				# Random position within spawn radius
				var spawn_offset = Vector3(
					randf_range(-spawn_radius, spawn_radius),
					0,
					randf_range(-spawn_radius, spawn_radius)
				)
				
				# Add to scene tree first
				get_parent().add_child(mob_instance)
				mob_instance.global_position = global_position + spawn_offset
				
				# Set spawn position if mob has it
				if mob_instance.has_method("set") and "spawn_position" in mob_instance:
					mob_instance.spawn_position = mob_instance.global_position
				
				# Connect death signal if available
				if mob_instance.has_signal("on_death"):
					mob_instance.on_death.connect(_on_mob_died.bind(mob_instance))
				
				spawned_mobs.append(mob_instance)
				print("MobArea: Spawned mob at ", mob_instance.global_position)
	
	has_spawned = true
	mobs_spawned.emit()

func _on_mob_died(mob: Node3D) -> void:
	spawned_mobs.erase(mob)
	
	if spawned_mobs.is_empty():
		all_mobs_defeated.emit()
		
		# Respawn after delay if not one-time
		if not one_time_spawn and is_player_in:
			await get_tree().create_timer(respawn_delay).timeout
			if is_player_in:
				spawn_mobs()

func activate() -> void:
	is_active = true

func deactivate() -> void:
	is_active = false
	# Clear all mobs
	for mob in spawned_mobs:
		if is_instance_valid(mob):
			mob.queue_free()
	spawned_mobs.clear()

func get_alive_mob_count() -> int:
	var count = 0
	for mob in spawned_mobs:
		if is_instance_valid(mob):
			if mob.has_method("get") and "is_dead" in mob:
				if not mob.is_dead:
					count += 1
			else:
				count += 1
	return count
