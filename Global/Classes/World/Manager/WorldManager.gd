# WorldManager.gd - Enhanced world manager that handles game world, player, and level management
extends Node3D
class_name World_Manager

signal game_started
signal game_paused
signal game_resumed
signal player_died
signal player_respawned

@export_category("World Configuration")
@export var levels: Array[PackedScene] = []
@export var player_scene: PackedScene

@export_category("References")
@export var level_manager: LevelManager

var current_player: player = null
var is_paused: bool = false
var _players_container: Node3D
var _players: Dictionary = {} # peer_id -> player node

func _ready() -> void:
	# Create players container
	_players_container = Node3D.new()
	_players_container.name = "Players"
	add_child(_players_container)
	
	# Setup level manager
	if not level_manager:
		level_manager = LevelManager.new()
		level_manager.name = "LevelManager"
		add_child(level_manager)
	
	level_manager.initialize_levels(levels)
	level_manager.level_changed.connect(_on_level_changed)
	level_manager.all_levels_completed.connect(_on_all_levels_completed)
	
	# Setup multiplayer peer connections
	if GameData.is_multiplayer:
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func start_game() -> void:
	# Load the appropriate level based on saved data
	var start_index = GameData.current_level_index
	
	# Load the level
	level_manager.load_level(start_index)
	
	# Spawn players based on mode
	if GameData.is_multiplayer:
		# Host spawns their own player
		if multiplayer.is_server() or GameData.is_host:
			spawn_player_for_peer(1) # Host is always peer 1
		else:
			# Clients spawn their own player
			spawn_player_for_peer(multiplayer.get_unique_id())
	else:
		# Singleplayer
		spawn_player()
	
	# Initialize HUD with current level info
	await get_tree().process_frame
	var current_level = level_manager.get_current_level()
	if current_level:
		var hud = get_hud()
		if hud and hud.has_method("update_level"):
			hud.update_level(current_level.level_name, start_index)
	
	game_started.emit()

func spawn_player() -> void:
	if not player_scene:
		push_error("Player scene not set in WorldManager!")
		return
	
	# Remove existing local player
	if current_player:
		current_player.queue_free()
		current_player = null
	
	# Instantiate player
	var player_instance = player_scene.instantiate() as player
	if player_instance:
		_players_container.add_child(player_instance, true)
		current_player = player_instance
		
		# Set player properties from GameData
		if current_player.props:
			current_player.props.Name = GameData.player_name
		current_player.sensitivity = GameData.mouse_sensitivity
		if current_player.Cam:
			current_player.Cam.fov = GameData.field_of_view
		
		# Connect death signal
		if current_player.props:
			current_player.props.dead.connect(_on_player_death)
		
		# Position player at spawn or checkpoint
		_position_player()

func spawn_player_for_peer(peer_id: int) -> void:
	if not player_scene:
		push_error("Player scene not set in WorldManager!")
		return
	
	# Check if player already exists for this peer
	if _players.has(peer_id):
		return
	
	var player_instance = player_scene.instantiate() as player
	if player_instance:
		player_instance.name = "Player_" + str(peer_id)
		_players_container.add_child(player_instance, true)
		player_instance.set_multiplayer_authority(peer_id)
		
		_players[peer_id] = player_instance
		
		# If this is our player, set as current
		if peer_id == multiplayer.get_unique_id() or (multiplayer.is_server() and peer_id == 1):
			current_player = player_instance
			
			# Set player properties from GameData
			if current_player.props:
				current_player.props.Name = GameData.player_name
			current_player.sensitivity = GameData.mouse_sensitivity
			if current_player.Cam:
				current_player.Cam.fov = GameData.field_of_view
				current_player.Cam.current = true
			
			# Connect death signal
			if current_player.props:
				current_player.props.dead.connect(_on_player_death)
		else:
			# Disable camera for other players
			if player_instance.has_node("Camera3D"):
				player_instance.get_node("Camera3D").current = false
		
		# Position player at spawn
		var spawn_pos = level_manager.get_spawn_position()
		spawn_pos.y += 1.5
		player_instance.global_position = spawn_pos
		
		print("Spawned player for peer: ", peer_id)

func _on_peer_connected(peer_id: int) -> void:
	print("Peer connected to world: ", peer_id)
	# Host spawns player for new peer
	if multiplayer.is_server():
		spawn_player_for_peer(peer_id)
		# Tell the new peer to spawn players for existing peers
		for existing_peer_id in _players.keys():
			if existing_peer_id != peer_id:
				rpc_id(peer_id, "_rpc_spawn_player", existing_peer_id)
		# Tell existing peers about new player
		for existing_peer_id in _players.keys():
			if existing_peer_id != peer_id and existing_peer_id != 1:
				rpc_id(existing_peer_id, "_rpc_spawn_player", peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer disconnected from world: ", peer_id)
	if _players.has(peer_id):
		var player_node = _players[peer_id]
		if is_instance_valid(player_node):
			player_node.queue_free()
		_players.erase(peer_id)

@rpc("authority", "call_local", "reliable")
func _rpc_spawn_player(peer_id: int) -> void:
	spawn_player_for_peer(peer_id)

func _position_player() -> void:
	if not current_player:
		return
	
	var spawn_pos = Vector3.ZERO
	
	# Check if we have a saved checkpoint
	if GameData.last_checkpoint_level == GameData.current_level_index and GameData.last_checkpoint_position != Vector3.ZERO:
		spawn_pos = GameData.last_checkpoint_position
	else:
		# Use level spawn point
		spawn_pos = level_manager.get_spawn_position()
	
	# Offset spawn slightly above ground
	spawn_pos.y += 1.5
	
	current_player.global_position = spawn_pos

func _on_player_death() -> void:
	player_died.emit()
	
	# Wait a moment before respawning
	await get_tree().create_timer(2.0).timeout
	respawn_player()

func respawn_player() -> void:
	if current_player:
		# Position at checkpoint or spawn FIRST (before respawn resets state)
		_position_player()
		
		# Call player's respawn method to reset all state
		if current_player.has_method("respawn"):
			current_player.respawn()
		else:
			# Fallback if respawn method missing
			current_player.is_dead = false
			if current_player.props:
				current_player.props.reset_health()
		
		player_respawned.emit()
		print("Player respawned at: ", current_player.global_position)

func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_paused.emit()

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	game_resumed.emit()

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()

# Property to expose players dictionary for HUD
var players: Dictionary:
	get:
		return _players

func _on_level_changed(from_index: int, to_index: int) -> void:
	GameData.current_level_index = to_index
	GameData.save_current_world()
	
	# Update HUD with new level info
	var current_level = level_manager.get_current_level()
	if current_level:
		var hud = get_hud()
		if hud and hud.has_method("update_level"):
			hud.update_level(current_level.level_name, to_index)
			print("WorldManager: Updated HUD with level - ", current_level.level_name)
	
	# Reposition player at new level spawn
	if current_player:
		await get_tree().process_frame
		_position_player()

func get_hud() -> Control:
	# Try to find HUD in scene tree
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		return hud
	# Fallback: search for HUD node
	hud = get_node_or_null("HUD")
	if not hud:
		hud = get_tree().current_scene.get_node_or_null("HUD")
	return hud

func _on_all_levels_completed() -> void:
	print("Congratulations! All levels completed!")
	# Return to main menu or show completion screen
	await get_tree().create_timer(3.0).timeout
	SceneManager.go_to_main_menu()

func save_checkpoint(checkpoint: CheckPoint) -> void:
	if checkpoint:
		GameData.update_checkpoint(checkpoint.global_position, GameData.current_level_index)

# Multiplayer functions
func open_to_lan(port: int) -> void:
	if GameData.is_multiplayer:
		return
	
	MultiplayerManager.create_Server(port)
	GameData.is_multiplayer = true
	GameData.is_host = true
	print("Server opened on port: " + str(port))

func close_lan() -> void:
	if not GameData.is_host:
		return
	
	MultiplayerManager.disconnect_from_server()
	GameData.is_multiplayer = false
	GameData.is_host = false
