# Player.gd - Player character class with input handling, camera, and combat
extends Entity
class_name player

signal on_interact
signal on_attack_pressed

@onready var Cam: Camera3D = $Camera3D if has_node("Camera3D") else null
@onready var L_Name: Label3D = $Label3D if has_node("Label3D") else null
@onready var sword_pivot: Node3D = $SwordPivot if has_node("SwordPivot") else null

@export_category("Player Settings")
@export var sensitivity: float = 0.005
@export var sprint_multiplier: float = 1.5
@export var attack_cooldown: float = 0.5

var is_sprinting: bool = false
var can_attack: bool = true
var last_checkpoint: CheckPoint = null

func is_local_player() -> bool:
	# In singleplayer, always true
	if not GameData.is_multiplayer:
		return true
	# In multiplayer, check authority
	return is_multiplayer_authority()

func _ready() -> void:
	super._ready()
	
	# Only configure camera and input for local player
	if is_local_player():
		# Apply settings from GameData
		if GameData:
			sensitivity = GameData.mouse_sensitivity
			if Cam:
				Cam.fov = GameData.field_of_view
				Cam.current = true
			if props:
				props.Name = GameData.player_name
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		# Disable camera for remote players
		if Cam:
			Cam.current = false
	
	set_data()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	super._physics_process(delta)
	
	# Only handle input for local player
	if is_local_player() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_handle_movement(delta)
		_handle_actions()

func _unhandled_input(event: InputEvent) -> void:
	if is_dead or not is_local_player():
		return
	
	# Camera look
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		if Cam:
			Cam.rotation_degrees.x -= event.relative.y * sensitivity * 57.3 # Convert to degrees
			Cam.rotation_degrees.x = clamp(Cam.rotation_degrees.x, -80, 80)
	
	# Pause menu
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			# Notify game to pause
			var world_manager = get_tree().get_first_node_in_group("world_manager")
			if world_manager and world_manager.has_method("toggle_pause"):
				world_manager.toggle_pause()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _handle_movement(_delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Fallback to ui inputs if custom inputs not set
	if input_dir == Vector2.ZERO:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprint check
	is_sprinting = Input.is_action_pressed("sprint") or Input.is_action_pressed("ui_shift")
	var current_speed = props.MoveSpeed
	if is_sprinting:
		current_speed *= sprint_multiplier
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Jump
	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_select")) and is_on_floor():
		jump(props.JumpForce)

func _handle_actions() -> void:
	# Attack
	if Input.is_action_just_pressed("attack") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if can_attack:
			perform_attack()
	
	# Interact
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
		on_interact.emit()

func perform_attack() -> void:
	if not can_attack or is_attacking:
		return
	
	can_attack = false
	on_attack_pressed.emit()
	
	# Call parent attack
	attack()
	
	# Play sword swing animation (if sword pivot exists)
	if sword_pivot:
		var tween = create_tween()
		tween.tween_property(sword_pivot, "rotation_degrees:x", -90, 0.15)
		tween.tween_property(sword_pivot, "rotation_degrees:x", 0, 0.2)
	
	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_death() -> void:
	# Don't queue_free - respawn instead
	is_dead = true
	print("Player " + props.Name + " died!")
	
	# Disable input
	set_physics_process(false)
	
	# Death animation/effect could go here
	
	# Let WorldManager handle respawn

func respawn() -> void:
	is_dead = false
	set_physics_process(true)
	if props:
		props.Health = props.MaxHealth

func set_data() -> void:
	if L_Name and props:
		L_Name.text = props.Name

func set_last_checkpoint(checkpoint: CheckPoint) -> void:
	last_checkpoint = checkpoint
	if GameData:
		GameData.update_checkpoint(checkpoint.global_position, GameData.current_level_index)

func apply_settings() -> void:
	if GameData and is_local_player():
		sensitivity = GameData.mouse_sensitivity
		if Cam:
			Cam.fov = GameData.field_of_view
		if props:
			props.Name = GameData.player_name
		set_data()
