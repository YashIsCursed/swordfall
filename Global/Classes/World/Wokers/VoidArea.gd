# VoidArea.gd - Area that kills the player when they enter (e.g., falling off the map)
extends ActionArea
class_name VoidArea

signal player_killed(player_ref: player)

@export_category("Void Settings")
## Damage amount to apply (set very high to instant-kill, or lower for gradual damage)
@export var damage_amount: int = 99999
## If true, instantly kills the player regardless of health
@export var instant_kill: bool = true
## Optional respawn delay before respawning the player (handled by WorldManager)
@export var respawn_delay: float = 0.0
## Grace period after world loads before void can kill (prevents spawn deaths)
@export var spawn_grace_period: float = 1.5
## Only kill if player is falling (has negative Y velocity)
@export var require_falling: bool = true

var _is_active: bool = false

func _init() -> void:
	super._init()
	# Void areas should only detect players
	detect_player_only = true
	# Usually one-shot is false so it can kill again after respawn
	one_shot = false

func _ready() -> void:
	# CRITICAL: Set collision mask to detect player (layer 2)
	# Player is on collision_layer = 2, so we need collision_mask = 2
	collision_layer = 0 # VoidArea doesn't need to be on any layer
	collision_mask = 2 # Detect bodies on layer 2 (player)
	
	# Start inactive to prevent spawn deaths
	_is_active = false
	
	# Call parent _ready to connect signals
	super._ready()
	
	# Activate after grace period
	await get_tree().create_timer(spawn_grace_period).timeout
	_is_active = true
	print("VoidArea now active")

func _on_player_enter_action(player_ref: player) -> void:
	if not player_ref:
		return
	
	# Don't kill during grace period
	if not _is_active:
		print("VoidArea: Player entered during grace period, ignoring")
		return
	
	# Optionally only kill if player is falling
	if require_falling and player_ref.velocity.y >= -1.0:
		print("VoidArea: Player not falling (velocity.y = ", player_ref.velocity.y, "), ignoring")
		return
	
	print("VoidArea: Player ", player_ref.props.Name if player_ref.props else "Unknown", " entered void!")
	
	if instant_kill:
		# Directly trigger death
		if player_ref.props:
			player_ref.props.Health = 0
	else:
		# Apply damage (may not kill if player has high health)
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(damage_amount)
	
	player_killed.emit(player_ref)
